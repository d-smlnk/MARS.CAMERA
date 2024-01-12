//
//  MainVC.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 11.01.2024.
//


/*
 Реалізувати додаток для перегляду фотографій з марсоходів використовуючи NASA API
 https://api.nasa.gov/index.html#browseAPI - Mars Rover Photos (auth key можна отримати за формою https://api.nasa.gov (https://api.nasa.gov/) )
 Згідно дизайну - https://www.figma.com/file/hS1HYIVr0lqACogIaZcAIi/Test?type=design&amp;node-id=0%3A1&mode=design&t=cAtOksQkzue9SH2D-1

 - Необхідно дати можливість користувачу обирати тип марсохода, камери та дати.
 - По натисканню на інформацию видображати фулскріново зображення (по можливості кешувати зображення)
 - Результат переглядів зберігати в БД (Realm або CoreData) з можливістю переглянути історію запитів на екрані та використати запит за історії.
 */

import UIKit
import SnapKit
import Lottie

protocol OpenImageDelegate: UIViewController {
    var delegatedImageURL: URL? { get set }
}

class MainVC: UIViewController, OpenImageDelegate {
    
    var delegatedImageURL: URL? // OpenImageDelegate variable
    
    private var animationView: LottieAnimationView?
    
    private var roverData: MarsRoverResponseModel?
    
    private let photoTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        launchScreen()
    }
    
    private func setupLayout() {
        view.backgroundColor = DS.Colors.backgroundOne
        
        let headerView = UIView()  //Orange header view
        headerView.backgroundColor = DS.Colors.accentOne
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowRadius = 5
        view.addSubview(headerView)
        
        let appTitleNameLabel = UILabel()
        appTitleNameLabel.text = "MARS.CAMERA"
        appTitleNameLabel.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.largeTitle)
        
        let todaysDateLabel = UILabel()
        todaysDateLabel.text = Methods.dateFormatter.string(from: Date())
        todaysDateLabel.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.body2)

        let headerTitleSV = UIStackView(arrangedSubviews: [appTitleNameLabel, todaysDateLabel])
        headerTitleSV.axis = .vertical
        headerTitleSV.distribution = .fillProportionally
        headerView.addSubview(headerTitleSV)
        
        let btnInsets = DS.SizeOfElements.btnInsets
        
        let calendarBtn = UIButton()
        calendarBtn.setImage(DS.Images.calendarIcon, for: .normal)
        calendarBtn.contentEdgeInsets = UIEdgeInsets(top: btnInsets,
                                                     left: btnInsets,
                                                     bottom: btnInsets,
                                                     right: btnInsets)
        headerView.addSubview(calendarBtn)
        
        let roverFilterBtn = UIButton()
        let cameraFilterBtn = UIButton()
        let addBtn = UIButton()
        
        let filterDataArray: [(UIButton, UIImage?, String?)] = [(roverFilterBtn, DS.Images.cpuIcon, "All"),
                                                                (cameraFilterBtn, DS.Images.cameraIcon, "All"),
                                                                (addBtn,DS.Images.plusIcon, nil)]
        
        filterDataArray.forEach { filterBtn, img, string in
            filterBtn.layer.cornerRadius = 10
            filterBtn.backgroundColor = DS.Colors.backgroundOne
            filterBtn.setImage(img, for: .normal)
            filterBtn.setTitle(string, for: .normal)
            filterBtn.titleLabel?.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.body2)
            filterBtn.setTitleColor(.black, for: .normal)
        }
        
        [roverFilterBtn, cameraFilterBtn].forEach {
            $0.contentHorizontalAlignment = .leading
            $0.contentEdgeInsets = UIEdgeInsets(top: btnInsets, left: btnInsets, bottom: btnInsets, right: 0)
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: btnInsets, bottom: 0, right: 0)
        }
        
        addBtn.contentHorizontalAlignment = .center
        
        let filterDataSV = UIStackView(arrangedSubviews: [roverFilterBtn, Methods.spacerView(12), cameraFilterBtn, Methods.spacerView(24), addBtn])
        filterDataSV.spacing = 0
        headerView.addSubview(filterDataSV)
                
        photoTableView.dataSource = self
        photoTableView.delegate = self
        photoTableView.register(CardTVC.self, forCellReuseIdentifier: CardTVC.reuseIdentifier)
        photoTableView.showsVerticalScrollIndicator = false
        photoTableView.separatorStyle = .none
        view.addSubview(photoTableView)
            
        //MARK: - CONSTRAINTS OF MAIN LAYOUT
        
        headerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(view.frame.height / 4.218)
        }
        
        headerTitleSV.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(2)
            $0.leading.equalToSuperview().inset(DS.Paddings.padding)
        }
        
        calendarBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(DS.Paddings.padding)
            $0.size.equalTo(DS.SizeOfElements.btnSize)
            $0.centerY.equalTo(headerTitleSV.snp.centerY)
        }
        
        filterDataSV.snp.makeConstraints {
            $0.top.equalTo(headerTitleSV.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(DS.Paddings.padding)
        }
        
        [roverFilterBtn, cameraFilterBtn].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(38)
                $0.width.equalTo(UIScreen.main.bounds.width / 2.8)
            }
        }
        
        addBtn.snp.makeConstraints {
            $0.size.equalTo(38)
        }
        
        photoTableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(DS.Paddings.padding)
            $0.horizontalEdges.equalToSuperview().inset(DS.Paddings.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(DS.Paddings.padding)
        }
    }
    
    private func launchScreen() { // Продолжение и анимация Лаунч Скрина
        view.backgroundColor = .white
        let image = DS.Images.launchScreenSquareIcon
        
        let squareIV = UIImageView()
        squareIV.image = image
        view.addSubview(squareIV)
                
        animationView = .init(name: "loader")
        
        guard let animationView = animationView else { return }
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.5
        view.addSubview(animationView)
        
        animationView.play { (finished) in
            if finished {
                squareIV.isHidden = true
                animationView.isHidden = true
                self.setupLayout()
                self.fetch()

            }
        }
    
        //MARK: - CONSTRAINTS OF ANIMATIONS
        
        squareIV.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        animationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(100)
            $0.width.equalTo(111)
            $0.height.equalTo(300)
        }
    }

}

//MARK: - TABLEVIEW SETUP

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return roverData?.photos.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTVC.reuseIdentifier, for: indexPath) as? CardTVC else { return UITableViewCell() }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cell.roverImageView.addGestureRecognizer(tapGesture)
        cell.roverData = roverData?.photos[indexPath.section]
        delegatedImageURL = roverData?.photos[indexPath.section].img_src
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
}

//MARK: - Completion of fetch method

extension MainVC {
    private func fetch() {
        MarsAPIService.shared.fetchRoverData { response in
            switch response {
            case .success(let roverData):
                self.roverData = roverData
                self.photoTableView.reloadData()
                print("fetching successed")
            case .failure(let error):
                print(error)
            }
        }
    }
}

//MARK: - @objc METHODS

extension MainVC {
    @objc func imageTapped() {
        let vc = FullScreenImageVC()
        vc.imageDelegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
