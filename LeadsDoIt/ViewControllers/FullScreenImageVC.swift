//
//  FullScreenImageVC.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 12.01.2024.
//

import UIKit
import Alamofire

class FullScreenImageVC: UIViewController {
    
    weak var imageDelegate: OpenImageDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        
        view.backgroundColor = .black
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        guard let imageURL = imageDelegate?.delegatedImageURL else { return }
        
        MarsAPIService.shared.getImageFromUrl(imageURL) { image in
            imageView.image = image
        }
        view.addSubview(imageView)
        
        let dissmissBtn = UIButton()
        dissmissBtn.setImage(DS.Images.closeIcon, for: .normal)
        dissmissBtn.addTarget(self, action: #selector(closeFullScreenImage), for: .touchUpInside)
        view.addSubview(dissmissBtn)

        //MARK: - CONSTRAINTS
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        dissmissBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(DS.Paddings.padding)
            $0.leading.equalToSuperview().inset(DS.Paddings.padding)
        }
    }

    @objc func closeFullScreenImage() {
        dismiss(animated: true, completion: nil)
    }

}
