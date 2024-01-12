//
//  CardTVC.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 11.01.2024.
//

import UIKit
import Alamofire

class CardTVC: UITableViewCell {
    
    private let roverLabel = UILabel()
    private let cameraLabel = UILabel()
    private let dateLabel = UILabel()
    let roverImageView = UIImageView()
    
    var roverData: PhotoModel?
    
    static let reuseIdentifier = "CardTVC"
    
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
        
        roverImageView.clipsToBounds = true
        roverImageView.layer.cornerRadius = 20
        roverImageView.isUserInteractionEnabled = true
        
        [roverLabel, cameraLabel, dateLabel].forEach {
            $0.numberOfLines = 0
        }
        
        [roverLabel, cameraLabel, dateLabel, roverImageView].forEach {
            contentView.addSubview($0)
        }
        
        //MARK: - CONSTRAINTS
        
        roverImageView.snp.makeConstraints {
            $0.size.equalTo(UIScreen.main.bounds.size.width / 3)
            $0.top.trailing.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(roverImageView.snp.width)
        }
        
        roverLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(roverImageView.snp.leading).offset(-10)
        }
        
        cameraLabel.snp.makeConstraints {
            $0.top.equalTo(roverLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(roverImageView.snp.leading).offset(-10)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(cameraLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(roverImageView.snp.leading).offset(-10)
            $0.bottom.equalToSuperview().inset(26)
        }
    }
    
    func configure() {
        guard let roverName = roverData?.rover.name,
              let cameraName = roverData?.camera.full_name,
              let dateTitle = roverData?.earth_date,
              let imageURL = roverData?.img_src else { return }
        
        roverLabel.attributedText = Methods.cardAttrributedText(key: "Rover", value: roverName)
        cameraLabel.attributedText = Methods.cardAttrributedText(key: "Camera", value: cameraName)
        dateLabel.attributedText =  Methods.cardAttrributedText(key: "Date", value: Methods.reformatingStringDate(dateTitle))
        
        MarsAPIService.shared.getImageFromUrl(imageURL) { image in
            self.roverImageView.image = image
        }
    }
}
