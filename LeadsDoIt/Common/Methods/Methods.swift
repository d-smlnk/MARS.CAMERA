//
//  Methods.swift
//  LeadsDoIt
//
//  Created by Дима Самойленко on 11.01.2024.
//

import Foundation
import UIKit

struct Methods {
    
    static func spacerView(_ width: CGFloat) -> UIView {
        let spacerView = UIView()
        spacerView.widthAnchor.constraint(equalToConstant: width).isActive = true
        return spacerView
    }
    
     static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    static func cardAttrributedText(key keyString: String, value valueString: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        
        let graySegment = NSAttributedString(string: "\(keyString): ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        attributedString.append(graySegment)
        
        let blackSegment = NSAttributedString(string: valueString, attributes: [NSAttributedString.Key
                                                                                .paragraphStyle: paragraphStyle,
                                                                                .foregroundColor: UIColor.black,
                                                                                .font: UIFont(name: DS.Fonts.SFPro.SFPro_bold, size: DS.FontSizes.body) ?? .systemFont(ofSize: 16)
                                                                               ])
        attributedString.append(blackSegment)
        
        return attributedString
    }
    
    static func reformatingStringDate(_ stringDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: stringDate) else { return ""}
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMMM, yyyy"
        
        var components = DateComponents()
            components.day = 1

        guard let newDate = Calendar.current.date(byAdding: components, to: date) else { return ""}
        
        let outputDateString = outputFormatter.string(from: newDate)
        return outputDateString
    }
    
}
