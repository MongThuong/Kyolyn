//
//  KLUIntClearField.swift
//  Kiolyn
//
//  Created by Anh Tai LE on 06/09/2018.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KLUIntClearField: KLTextField {
    
    var shouldClearInFirstTime: Bool = false
    var minValue: UInt = 0
    var maxValue: UInt = UInt.max
    
    var value: UInt = 0 {
        didSet {
            text = "\(self.value)"
            sendActions(for: .valueChanged)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override init(_ theme: Theme = .light, placeholder: String = "") {
        super.init(theme, placeholder: placeholder)
        delegate = self
    }
}

extension Reactive where Base: KLUIntClearField {
    /// Reactive wrapper for `text` property.
    var value: ControlProperty<UInt> {
        return base.rx.controlProperty(
            editingEvents: [.allEditingEvents, .valueChanged],
            getter: { $0.value },
            setter: { field, value in field.value = value }
        )
    }
}

extension KLUIntClearField: KeyActionHandler {
    func interested(in: KeyAction) -> Bool {
        return true
    }
    
    func apply(key: KeyAction) {
        apply(key: key, to: self)
    }
    
    func apply(key: KeyAction, to field: UITextField) {
        switch key {
        case .char(let char):
            guard let v = UInt(char) else { return }
            if shouldClearInFirstTime {
                shouldClearInFirstTime = false
                value = 0
            }
            let nvalue = value * 10 &+ v
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        case .clear:
            self.value = 0
        case .backspace:
            let nvalue = value / 10
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        case .add(let v):
            let nvalue = value &+ v
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        case .minus(let v):
            let nvalue = value &- v
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        default: return
        }
    }
}

extension KLUIntClearField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let _ = UInt(string) else { return false }
        return true
    }
}
