//
//  KLCashField.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/10/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For inputting unsigned intergral numbers.
class KLCashField: KLTextField {
    var minValue: Double = 0
    var maxValue: Double = 99999999
    
    var value: Double = 0.0 {
        didSet {
            text = value.asMoney
            sendActions(for: .valueChanged)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override init(_ theme: Theme = .light, placeholder: String = "") {
        super.init(theme, placeholder: placeholder)
    }
}

extension Reactive where Base: KLCashField {
    /// Reactive wrapper for `text` property.
    var doubleValue: ControlProperty<Double> {
        return base.rx.controlProperty(
            editingEvents: [.allEditingEvents, .valueChanged],
            getter: { field in field.value },
            setter: { field, value in field.value = value }
        )
    }
}

extension KLCashField: KeyActionHandler {
    func interested(in: KeyAction) -> Bool {
        return true
    }
    
    func apply(key: KeyAction, to field: UITextField) {
        let cashValue = lround(value*100)
        switch key {
        case .char(let char):
            guard let v = Int(char) else { return }
            let nvalue = Double((cashValue*10 + v))/100
            if nvalue >= minValue && nvalue <= maxValue {
                value = nvalue
            }
        case .clear:
            value = 0
        case .backspace:
            let nvalue = Double(cashValue/10)/100
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        case .add(let v):
            let nvalue = value + Double(v)
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        case .minus(let v):
            let nvalue = value - Double(v)
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        default: return
        }
    }
}

extension KLCashField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let _ = Double(string) else { return false }
        return true
    }
}


