//
//  UILabel+FAK.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import FontAwesomeKit

extension UILabel {
    
    /// Convenient icon setting.
    var fakIcon: FAKIcon {
        set {
            set(icon: newValue)
        }
        get {
            fatalError("Invalid operation - having it here to avoid compiler error")
        }
    }
    
    /// Set icon with text and font.
    ///
    /// - Parameters:
    ///   - getIcon: to get the icon.
    ///   - text: the text string to set.
    func set(icon getIcon: @autoclosure () -> FAKIcon, withText text: String? = nil) {
        let icon = getIcon()
        icon.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: textColor)
        let str = NSMutableAttributedString(attributedString: icon.attributedString())
        if let text = text, text.isNotEmpty {
            str.append(NSAttributedString(string: "  \(text)", attributes: [
                NSAttributedStringKey.foregroundColor: textColor as Any,
                NSAttributedStringKey.font: font as Any]))
        }
        attributedText = str
    }
}
