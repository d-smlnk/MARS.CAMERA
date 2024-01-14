//
//  UIView_SHADOW.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 13.01.2024.
//

import Foundation
import UIKit

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
    }
}
