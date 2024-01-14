//
//  PickerWithToolbar.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 13.01.2024.
//

import UIKit

class PickerWithToolbar: NSObject {

    private var pickerView: UIPickerView?
    private var toolBar: UIToolbar?
    
    weak var delegate: PickerWithToolbarDelegate?
    
    private let pickerElementsArray: [String]?
    private let pickerElementsDictionary: [String : String]?
    
    init(pickerElementsArray: [String]? = nil, pickerElementsDictionary: [String : String]? = nil) {
        self.pickerElementsArray = pickerElementsArray
        self.pickerElementsDictionary = pickerElementsDictionary
        super.init()
    }

    func createPickerView(_ vc: UIViewController) -> UIPickerView {
        let pickerView = UIPickerView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.backgroundColor = DS.Colors.backgroundOne
        pickerView.layer.cornerRadius = pickerView.frame.height / 12
        pickerView.addShadow()
        
        self.pickerView = pickerView
        
        vc.view.addSubview(pickerView)

        return pickerView
    }

    func createToolBar(title: String, _ vc: UIViewController) -> UIToolbar {
        let pickerTitle = UILabel()
        pickerTitle.text = title
        pickerTitle.font = UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.title)

        let titleElement = UIBarButtonItem(customView: pickerTitle)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(image: DS.Images.donePickerIcon, style: .done, target: self, action: #selector(onDoneButtonTapped))
        let closeBtn = UIBarButtonItem(image: DS.Images.closePickerIcon, style: .done, target: self, action: #selector(onCloseButtonTapped))

        let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barTintColor = DS.Colors.backgroundOne
        toolBar.items = [closeBtn, flexibleSpace, titleElement, flexibleSpace, doneBtn]
        toolBar.items?.first?.tintColor = .black
        toolBar.items?.last?.tintColor = .orange
        toolBar.layer.cornerRadius = toolBar.frame.height / 2
        toolBar.clipsToBounds = true
        toolBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.toolBar = toolBar
        
        vc.view.addSubview(toolBar)

        return toolBar
    }

    @objc func onCloseButtonTapped() {
        delegate?.onCloseButtonTapped()
        toolBar?.removeFromSuperview()
        pickerView?.removeFromSuperview()
    }
    
    @objc func onDoneButtonTapped() {
        guard let row = pickerView?.selectedRow(inComponent: 0) else { return }
        let sortedDictionary = pickerElementsDictionary?.sorted(by: { $0 < $1 })
        
        if pickerElementsArray != nil, let pickerElementsArray = pickerElementsArray {
            delegate?.onDoneButtonTapped(pickerElementsArray[row])
        } else if pickerElementsDictionary != nil {
            delegate?.onDoneButtonTapped(sortedDictionary?[row].value ?? "")
        }
        toolBar?.removeFromSuperview()
        pickerView?.removeFromSuperview()
    }
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension PickerWithToolbar: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerElementsArray != nil {
            return pickerElementsArray?.count ?? 0
        } else if pickerElementsDictionary != nil {
            return pickerElementsDictionary?.count ?? 0
        }
        return Int()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        let sortedDictionary = pickerElementsDictionary?.sorted(by: { $0 < $1 })
        
        if pickerElementsArray != nil {
            return pickerElementsArray?[row] ?? ""
        } else if pickerElementsDictionary != nil {
            return sortedDictionary?[row].key
        }
        
        return String()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 28
    }
}

