//
//  LoginTextField.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

/// The common text field to be used inside Login screen.
class LoginTextField: TextField {
    fileprivate let theme =  Theme.loginTheme
    fileprivate var tempPlaceholer: String? = nil

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)

        // Disable keyboard
        inputView = UIView()
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []

        isClearIconButtonEnabled = false
        clearButtonMode = .never
        textAlignment = .center
        placeholder = nil
        textColor = theme.textColor
        tintColor = theme.textColor
        dividerColor = theme.dividersColor
        dividerNormalColor = theme.dividersColor
        dividerActiveColor = theme.secondary.base
        placeholderActiveColor = theme.secondaryTextColor
        placeholderNormalColor = theme.secondaryTextColor
        backgroundColor = UIColor(hex: 0x000000, alpha: 0.25)
    }

    func set(placeholder: String) {
        tempPlaceholer = placeholder
        self.placeholder = placeholder
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 4, dy: 4)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 4, dy: 4)
    }

    override func becomeFirstResponder() -> Bool {
        placeholder = nil
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        placeholder = nil

        if let text = self.text {
            if text == "" { placeholder = tempPlaceholer }
        } else {
            placeholder = tempPlaceholer
        }
        return super.resignFirstResponder()
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = isEnabled ? 1.0 : 0.5
        }
    }
}

