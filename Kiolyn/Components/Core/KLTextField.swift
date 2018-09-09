//
//  KLTextField.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/7/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// Base class for all text fields.
class KLTextField: Material.TextField {
    
    var theme: Theme!
    
    open override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = .light, placeholder: String = "") {
        self.theme = theme
        super.init(frame: .zero)
        
        // Disable keyboard
        inputView = UIView()
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
    }

    override func prepare() {
        super.prepare()
        
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
        clearButtonMode = .never
        isClearIconButtonEnabled = false
        dividerNormalColor = theme.dividersColor
        dividerActiveColor = theme.primary.base
        placeholderNormalColor = theme.secondaryTextColor
        placeholderActiveColor = theme.primary.base
    }
    
    override func becomeFirstResponder() -> Bool {
        sendActions(for: .didBecomeFirstResponder)
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        sendActions(for: .didResignFirstResponder)
        return super.resignFirstResponder()
    }
}

extension UIControlEvents {
    static var didBecomeFirstResponder: UIControlEvents { return UIControlEvents(rawValue: 0b0001 << 24) }
    static var didResignFirstResponder: UIControlEvents { return UIControlEvents(rawValue: 0b0010 << 24) }
}


