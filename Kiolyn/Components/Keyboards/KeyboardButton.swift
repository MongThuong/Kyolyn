//
//  KeyboardButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// Generic keyboard button
class KeyboardButton: RaisedButton, KLThemeButton {
    var theme: Theme { return Theme.keyboardTheme }
    var action: KeyAction? = nil
    var row: Int = 0
    var column: Int = 0
    var rowSpan: Int = 1
    var columnSpan: Int = 1
    
    open override func prepare() {
        super.prepare()
        backgroundColor = UIColor(hex: 0xe6e6e6)
        titleLabel?.font = theme.heading2Font
        setTitleColor(theme.primary.base, for: .normal)
        setTitleColor(theme.warn.base, for: .highlighted)
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.25
        }
    }
}

// MARK: - Factory
extension KeyboardButton {
    /// Create for normal keyboard.
    ///
    /// - Parameters:
    ///   - char: The title to be displayed.
    ///   - row: The row to be displayed.
    ///   - column: The column to be displayed
    ///   - rowSpan: The row span.
    ///   - columnSpan: The column span.
    ///   - action: The action to be performed, nil equal to normal key action with title as key.
    static func create(for title: String, row: Int, column: Int, rowSpan: Int = 1, columnSpan: Int = 1, action: KeyAction? = nil) -> KeyboardButton {
        let button = KeyboardButton()
        button.setTitle(title, for: .normal)
        button.action = action ?? KeyAction.char(title)
        button.row = row
        button.column = column
        button.rowSpan = rowSpan
        button.columnSpan = columnSpan
        return button
    }
    
    /// Init for normal keyboard.
    ///
    /// - Parameters:
    ///   - icon: The GMDIcon to be displayed.
    ///   - row: The row to be displayed.
    ///   - column: The column to be displayed
    ///   - rowSpan: The row span.
    ///   - columnSpan: The column span.
    ///   - action: The action to be performed.
    static func create(for icon: @autoclosure () -> FAKIcon, row: Int, column: Int, rowSpan: Int = 1, columnSpan: Int = 1, action: KeyAction? = nil) -> KeyboardButton {
        let button = KeyboardButton()
        button.set(icon: icon())
        button.action = action
        button.row = row
        button.column = column
        button.rowSpan = rowSpan
        button.columnSpan = columnSpan
        return button
    }
}

// MARK: - Key Action definitions

protocol KeyActionHandler {
    func interested(in: KeyAction) -> Bool
    func apply(key: KeyAction, to field: UITextField)
}


/// For handling fields navigation (tab)
class KeyNavigationHandler {
    var textFields: [UITextField] = []
    func move(nextOf field: UITextField?) -> UITextField? {
        // No given field, just try to return the first element on list
        guard let field = field else { return textFields.first }
        // If the text fields is empty, return the field itself
        guard textFields.isNotEmpty else { return field }
        // Try to locate the field inside the managed text fields
        guard var index = textFields.index(of: field) else { return textFields.first! }
        index += 1 // Move next
        if index == textFields.count { index = 0 } // Circle back
        let target = textFields[index]
        if target.isEnabled {
            target.becomeFirstResponder()
            return target
        } else { return move(nextOf: target) }
    }
    func move(previousOf field: UITextField?) -> UITextField? {
        // No given field, just try to return the last element on list
        guard let field = field else { return textFields.last }
        // If the text fields is empty, return the field itself
        guard textFields.isNotEmpty else { return field }
        // Try to locate the field inside the managed text fields
        guard var index = textFields.index(of: field) else { return textFields.first! }
        index -= 1 // Move prev
        if index < 0 { index = textFields.count - 1 } // Circle back
        let target = textFields[index]
        if target.isEnabled {
            target.becomeFirstResponder()
            return target
        } else { return move(previousOf: target) }
    }
}

typealias KeyCustomHandler = () -> Void

/// The content modification action key.
///
/// - char: Append char to the end of text.
/// - clear: Clear text.
/// - backspace: Remove the last char at the end of text.
/// - add: Add 1, the text field handler should take care of this.
/// - minus: Minus 2, the text field handler should take care of this.
enum KeyAction {
    case char(_: String)
    case clear
    case caplock
    case backspace
    case add(_: UInt)
    case minus(_: UInt)
    case next
    case prev
    
    var isNavigation: Bool {
        switch self {
        case .next: fallthrough
        case .prev: return true
        default: return false
        }
    }
    
    func apply(to field: UITextField?, allCaps: Bool = false) {
        // Require an active field to do the work
        guard let field = field else { return }
        // Let the text field do it first
        if let handler = field as? KeyActionHandler, handler.interested(in: self) {
            return handler.apply(key: self, to: field)
        }
        // Default handler
        guard field.isFirstResponder else { return }
        
        let text = field.text ?? ""
        
        switch self {
        case .char(var char):
            if allCaps { char = char.uppercased() }
            field.text = "\(text)\(char)"
        case .clear:
            field.text = ""
        case .backspace:
            if !text.isEmpty {
                field.text = text.exact(text.count-1)
            } else {
                field.text = ""
            }
        default: return
        }
        // Send action to mimic value changed
        field.sendActions(for: .valueChanged)
    }
}
