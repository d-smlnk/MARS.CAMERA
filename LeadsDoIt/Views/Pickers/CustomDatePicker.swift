//
//  CustomDatePicker.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 14.01.2024.
//

import Foundation
import UIKit

class CustomDatePicker: NSObject {
    
    var datePicker: UIDatePicker?
    private var toolBar: UIToolbar?
    
    private var blurredEffectView: UIVisualEffectView?
    
    private let toolBarHeight: CGFloat = 50
    
    weak var delegate: PickerWithToolbarDelegate?
    
    func addBlur(_ vc: UIViewController) {
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.5
        
        self.blurredEffectView = blurredEffectView
        
        vc.view.addSubview(blurredEffectView)
        
        blurredEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func createDatePicker(_ vc: UIViewController) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.backgroundColor = DS.Colors.backgroundOne
        datePicker.layer.cornerRadius = toolBarHeight / 2
        datePicker.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        datePicker.clipsToBounds = true
        
        self.datePicker = datePicker
        
        vc.view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(vc.view.snp.centerY).offset(-50)
            $0.horizontalEdges.equalToSuperview().inset(40)
            $0.height.equalTo(datePicker.snp.width).inset(50)
        }

        return datePicker
    }

    func createToolBar(title: String, _ vc: UIViewController) -> UIToolbar {
        let pickerTitle = UILabel()
        pickerTitle.text = title
        pickerTitle.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.title)

        let titleElement = UIBarButtonItem(customView: pickerTitle)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(image: DS.Images.donePickerIcon, style: .done, target: self, action: #selector(onDoneButtonTapped))
        let closeBtn = UIBarButtonItem(image: DS.Images.closePickerIcon, style: .done, target: self, action: #selector(onCloseButtonTapped))
        
        let toolBar = UIToolbar()
        toolBar.barTintColor = DS.Colors.backgroundOne
        toolBar.backgroundColor = DS.Colors.backgroundOne
        toolBar.items = [closeBtn, flexibleSpace, titleElement, flexibleSpace, doneBtn]
        toolBar.items?.first?.tintColor = .black
        toolBar.items?.last?.tintColor = .orange
        toolBar.layer.cornerRadius = toolBarHeight / 2
        toolBar.clipsToBounds = true
        toolBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.toolBar = toolBar
        
        vc.view.addSubview(toolBar)

        toolBar.snp.makeConstraints {
            $0.bottom.equalTo(vc.view.snp.centerY).offset(-50)
            $0.height.equalTo(toolBarHeight)
            $0.horizontalEdges.equalToSuperview().inset(40)
        }
        
        return toolBar
    }

    @objc func onCloseButtonTapped() {
        toolBar?.removeFromSuperview()
        datePicker?.removeFromSuperview()
        blurredEffectView?.removeFromSuperview()
    }
    
    @objc func onDoneButtonTapped() {
        delegate?.onDoneButtonTapped(nil)
        toolBar?.removeFromSuperview()
        datePicker?.removeFromSuperview()
        blurredEffectView?.removeFromSuperview()
    }

}
