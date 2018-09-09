//
//  UIButton+FAK.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import FontAwesomeKit

extension UIButton {
    
    /// Convenient icon setting.
    var fakIcon: FAKIcon {
        set { set(icon: newValue) }
        get { fatalError("Invalid operation - having it here to avoid compiler error") }
    }
    
    /// Set icon with text and font.
    ///
    /// - Parameters:
    ///   - getIcon: to get the icon.
    ///   - text: the text string to set.
    func set(icon getIcon: @autoclosure () -> FAKIcon, withText text: String? = nil) {
        let color = titleColor(for: .normal)
        let font = titleLabel?.font
        let icon = getIcon()
        icon.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: color)
        let str = NSMutableAttributedString(attributedString: icon.attributedString())
        if let text = text, text.isNotEmpty {
            str.append(NSAttributedString(string: "  \(text)", attributes: [
                NSAttributedStringKey.foregroundColor: color as Any,
                NSAttributedStringKey.font: font as Any]))
        }
        setAttributedTitle(str, for: .normal)        
    }
    
    /// Change icon color for a UIButton.
    ///
    /// - Parameter color: the new color.
    func set(iconColor color: UIColor) {
        guard let attr = attributedTitle(for: .normal) else {
            return
        }
        let attrTitle = NSMutableAttributedString(attributedString: attr)
        attrTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: color as Any, range: NSMakeRange(0, attrTitle.length))
        setAttributedTitle(attrTitle, for: .normal)
    }
}
