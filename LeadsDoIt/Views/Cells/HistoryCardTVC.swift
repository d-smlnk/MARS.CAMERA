//
//  HistoryCardTVC.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 13.01.2024.
//

import UIKit

class HistoryCardTVC: UITableViewCell {

    static let reuseIdentifier = "HistoryCardTVC"
    
    private let roverLabel = UILabel()
    private let cameraLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.backgroundColor = DS.Colors.backgroundOne
        contentView.layer.cornerRadius = 30
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 2
        selectionStyle = .none
        
        let decorView = UIView()
        decorView.backgroundColor = DS.Colors.accentOne
        
        let filterTitleLabel = UILabel()
        filterTitleLabel.text = "Filters"
        filterTitleLabel.textColor = DS.Colors.accentOne
        filterTitleLabel.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.title)
        
        let decorSV = UIStackView(arrangedSubviews: [(decorView, filterTitleLabel)].map({ decor, label in
            let customView = UIView()
   
            [decor, label].forEach {
                customView.addSubview($0)
            }
            
            decor.snp.makeConstraints {
                $0.height.equalTo(1)
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview()
            }
            
            label.snp.makeConstraints {
                $0.verticalEdges.trailing.equalToSuperview()
                $0.leading.equalTo(decor.snp.trailing).offset(6)
            }
            
            return customView
        }))
        
        contentView.addSubview(decorSV)
    
        [roverLabel, cameraLabel, dateLabel].forEach {
            $0.numberOfLines = 0
            contentView.addSubview($0)
        }
        
        //MARK: - CONSTRAINTS
        
        decorSV.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(10)
        }
        
        roverLabel.snp.makeConstraints {
            $0.top.equalTo(decorSV.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(16)
        }
        
        cameraLabel.snp.makeConstraints {
            $0.top.equalTo(roverLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(cameraLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(26)
        }
    }
    
    func configure() {
        roverLabel.attributedText = Methods.cardAttrributedText(key: "Rover", value: "roverName")
        cameraLabel.attributedText = Methods.cardAttrributedText(key: "Camera", value: "cameraName")
        dateLabel.attributedText =  Methods.cardAttrributedText(key: "Date", value: Methods.reformatingStringDate("dateTitle"))
    }
    
}
