//
//  DesignSystem.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 11.01.2024.
//

import Foundation
import UIKit

struct DS {
    
    struct Colors {
        static let backgroundOne = UIColor(hex: 0xFFFFFF)
        static let accentOne = UIColor(hex: 0xFF692C)
    }
    
    struct FontSizes {
        static let largeTitle: CGFloat = 34
        static let title: CGFloat = 22
        static let body: CGFloat = 16
        static let body2: CGFloat = 17
    }
    
    struct Fonts {
        
        struct SFPro {
            static let SFPro_semi_bold_italic = "SF Pro Display Semibold Italic"
            static let SFPro_black_italic = "SF PRO DISPLAY BLACK ITALIC"
            static let SFPro_bold = "SF Pro Display Bold"
            static let SFPro_heavy_italic = "SFPRODISPLAYHEAVYITALIC"
            static let SFPro_light_italic = "SFPRODISPLAYLIGHTITALIC"
            static let SFPro_medium = "SFPRODISPLAYMEDIUM"
            static let SFPro_regular = "SF Pro Display Regular"
            static let SFPro_thin_italic = "SFPRODISPLAYTHINITALIC"
            static let SFPro_ultra_light_italic = "SFPRODISPLAYULTRALIGHTITALIC"
        }
        
    }
    
    struct Paddings {
        static let padding = 20
    }
    
    struct SizeOfElements {
        static let btnSize = 50
        static let btnInsets: CGFloat = 6
    }
    
    struct Images {
        static let launchScreenSquareIcon = UIImage(named: "launchScreenSquare")
        static let calendarIcon = UIImage(named: "calendar")
        static let cpuIcon = UIImage(named: "cpu")
        static let cameraIcon = UIImage(named: "camera")
        static let plusIcon = UIImage(named: "plus")
        static let closeIcon = UIImage(named: "close")
    }
}
