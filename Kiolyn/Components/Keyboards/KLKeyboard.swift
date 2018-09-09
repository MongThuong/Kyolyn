//
//  KLKeyboard.swift
//  kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

let keyboardIconSize: CGFloat = 24.0

/// The base class for all keyboards, should not use this instance directly but via one of its child classes.
class KLKeyboard: KLView {
    let disposeBag = DisposeBag()
    
    // MARK: - Styling
    
    /// Return the number of rows.
    var rowCount: Int { return 4 }
    
    /// Return the number of columns.
    var columnCount: Int { return 4 }
    
    /// Margin around a button
    var keyMargin: Int { return 4 }
    
    /// Margin around a button
    var keyMarginX2: Int { return keyMargin * 2 }
    
    /// Size of a button in term of 1x1
    var keySize: Int { return 64 }
    
    /// The border thickness.
    var borderThickness: Int = 4
    
    /// Total width of the keyboard
    var expectedWidth: Int { return (keySize + keyMarginX2) * columnCount + borderThickness * 2 + keyMarginX2 }
    
    /// Total width of the keyboard
    var expectedHeight: Int { return (keySize + keyMarginX2) * rowCount  + borderThickness * 2 + keyMarginX2 }
    //    // Custom actions
    //    var keyActionToggleModifierShift: KeyAction!
    
    // MARK: - Buttons

    /// Child class provide its own definition for buttons.
    lazy var buttons: [KeyboardButton] = { return createButtons() }()
    func createButtons() -> [KeyboardButton] { return [] }
    
    /// Return the common return button.
    lazy var returnButton: KeyboardButton? = { return createReturnButton() }()
    func createReturnButton() -> KeyboardButton? { return nil }
    
    lazy var caplockButton: KeyboardButton? = { return createCaplockButton() }()
    func createCaplockButton() -> KeyboardButton? { return nil }

    /// The navigation handler
    lazy var navigationHandler: KeyNavigationHandler = { return KeyNavigationHandler() }()
    
    // MARK: - Input fields
    
    /// Return ALL the text field that are bound to this keyboard.
    var textFields: [UITextField] = [] {
        didSet {
            self.navigationHandler.textFields = textFields
        }
    }
    
    /// Return the current active text field.
    var currentTextField: UITextField?
    
    /// `true` if upppercase.
    var allCaps = false {
        didSet {
            if let button = caplockButton, let color = allCaps ? button.titleColor(for: .highlighted) : button.titleColor(for: .normal) {
                button.set(iconColor: color)
            }
            for button in buttons {
                if let title = button.title(for: .normal) {
                    button.setTitle(allCaps ? title.uppercased() : title.lowercased(), for: .normal)
                }
            }
        }
    }
    
    // MARK: - Layout
    
    /// Layout buttons as configured.
    override func prepare() {
        super.prepare()
        
        clipsToBounds = true

        backgroundColor = UIColor(hex: 0x1d2d36)
        layer.borderWidth = CGFloat(borderThickness)
        layer.borderColor = UIColor(hex: 0xe6e6e6).cgColor
        layer.cornerRadius = 2.0

        // Populate key buttons
        for button in buttons {
            addSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalTo((keySize + keyMarginX2) * button.columnSpan - keyMarginX2)
                make.height.equalTo((keySize + keyMarginX2) * button.rowSpan - keyMarginX2)
                make.left.equalTo((keySize + keyMarginX2) * button.column + keyMarginX2 + borderThickness)
                make.top.equalTo((keySize + keyMarginX2) * button.row + keyMarginX2 + borderThickness)
            }
            // Hook tap
            button.rx.tap
                .subscribe(onNext: { _ in
                    // No action - no thing to do
                    guard let action = button.action else { return }
                    self.updateFirstResponder()
                    switch action {
                    case .next: self.currentTextField = self.navigationHandler.move(nextOf: self.currentTextField)
                    case .prev: self.currentTextField = self.navigationHandler.move(previousOf: self.currentTextField)
                    case .caplock: self.allCaps = !self.allCaps
                    default: action.apply(to: self.currentTextField, allCaps: self.allCaps)
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    /// Try to set the active text field.
    final func updateFirstResponder() {
        // If the current text field is the first responder, just ignore
        if let currentTextField = self.currentTextField, currentTextField.isFirstResponder {
            return
        }
        // Find the first responder
        self.currentTextField = textFields.first(where: { t in t.isFirstResponder })
    }
}
