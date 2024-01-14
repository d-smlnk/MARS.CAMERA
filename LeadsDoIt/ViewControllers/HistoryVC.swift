//
//  HistoryVC.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 13.01.2024.
//

import UIKit
import RealmSwift

protocol SendSavedFilterDelegate: UIViewController {  // Sendind data back from HistoryVC to MainVC
    func sendSavedFilter(roverName: String, cameraName: String, date: Date)
}

class HistoryVC: UIViewController {

    private var realmDataArray: Results<RealmHistoryService>?
    
    weak var sendFilterDelegate: SendSavedFilterDelegate?
    
    private var emptyHistorySV = UIStackView()
    private var historyTV = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    private func setupLayout() {
        realmDataArray = RealmService.realm?.objects(RealmHistoryService.self)
        
        view.backgroundColor = DS.Colors.backgroundOne
        
        let headerView = UIView()  //Orange header view
        headerView.backgroundColor = DS.Colors.accentOne
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowRadius = 5
        view.addSubview(headerView)
        
        let backBtn = UIButton()
        backBtn.setImage(DS.Images.backIcon, for: .normal)
        backBtn.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        headerView.addSubview(backBtn)
        
        let historyTitleLabel = UILabel()
        historyTitleLabel.text = " History"
        historyTitleLabel.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.largeTitle)
        headerView.addSubview(historyTitleLabel)

        let emptyHistoryImageView = UIImageView()
        emptyHistoryImageView.image = DS.Images.ballIcon
        emptyHistoryImageView.contentMode = .scaleAspectFit
        
        let emptyHistoryLabel = UILabel()
        emptyHistoryLabel.text = "Browsing history is empty."
        emptyHistoryLabel.font = UIFont(name: DS.Fonts.SFPro.SFPro_regular, size: DS.FontSizes.body)
        emptyHistoryLabel.textColor = .gray
        emptyHistoryLabel.textAlignment = .center
        
        emptyHistorySV = UIStackView(arrangedSubviews: [emptyHistoryImageView, emptyHistoryLabel])
        emptyHistorySV.axis = .vertical
        emptyHistorySV.spacing = CGFloat(DS.Paddings.padding)
        view.addSubview(emptyHistorySV)
        
        historyTV = UITableView()
        historyTV.dataSource = self
        historyTV.delegate = self
        historyTV.register(HistoryCardTVC.self, forCellReuseIdentifier: HistoryCardTVC.reuseIdentifier)
        historyTV.separatorStyle = .none
        view.addSubview(historyTV)
        
        //MARK: - CONSTRAINTS
        
        headerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(view.frame.height / 6.45)
        }
        
        backBtn.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(DS.Paddings.padding)
        }
        
        historyTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backBtn)
        }
        
        emptyHistorySV.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(emptyHistorySV.snp.width)
        }
        
        historyTV.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(DS.Paddings.padding)
            $0.horizontalEdges.equalToSuperview().inset(DS.Paddings.padding)
            $0.bottom.equalToSuperview()
        }
        
    }

}

//MARK: - TABLEVIEW DATA SOURCE & DELEGATE

extension HistoryVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if realmDataArray?.count == 0 {
            historyTV.isHidden = true
            emptyHistorySV.isHidden = false
        } else {
            historyTV.isHidden = false
            emptyHistorySV.isHidden = true
        }
        return realmDataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCardTVC.reuseIdentifier, for: indexPath) as? HistoryCardTVC else { return UITableViewCell() }
        cell.realmData = realmDataArray?[indexPath.section]
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "Menu Filter", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Use", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let roverName = realmDataArray?[indexPath.section].roverName,
                  let cameraName = realmDataArray?[indexPath.section].cameraName,
                  let date = realmDataArray?[indexPath.section].date else { return }
            
            sendFilterDelegate?.sendSavedFilter(roverName: roverName, cameraName: cameraName, date: date)
            dismiss(animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            guard let objectToDelete = realmDataArray?[indexPath.section] else { return }

            do {
                try? RealmService.realm?.write {
                    RealmService.realm?.delete(objectToDelete)
                }
            }

            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
}

// MARK: - @objc METHODS

extension HistoryVC {
    @objc func back() {
        dismiss(animated: true)
    }
}
