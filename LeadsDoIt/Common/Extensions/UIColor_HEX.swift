//
//  UIColor_HEX.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 11.01.2024.
//

import Foundation
import UIKit

extension UIColor {
    convenience init?(hex: Int) {
        if (hex > 0xFFFFFF || hex < 0x000000) {
            return nil
        }
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
