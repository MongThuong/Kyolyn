//
//  KLPercentField.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/10/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For inputting unsigned intergral numbers.
class KLPercentField: KLTextField {
    var minValue: Double = 0
    var maxValue: Double = 1
    
    var value: Double = 0 {
        didSet {
            text = String(format: "%.02f%%", value*100)
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

extension Reactive where Base: KLPercentField {
    /// Reactive wrapper for `text` property.
    var value: ControlProperty<Double> {
        return base.rx.controlProperty(
            editingEvents: [.allEditingEvents, .valueChanged],
            getter: { $0.value },
            setter: { field, value in field.value = value }
        )
    }
}

extension KLPercentField: KeyActionHandler {    
    func interested(in: KeyAction) -> Bool {
        return true
    }
    
    func apply(key: KeyAction, to field: UITextField) {
        switch key {
        case .char(let char):
            guard let v = UInt(char) else { return }
            let uivalue = UInt(round(value*10000))
            let nvalue = uivalue*10 + v
            if nvalue >= UInt(round(minValue*10000)), nvalue <= UInt(round(maxValue*10000)) {
                value = Double(nvalue)/10000
            }
        case .clear:
            value = 0
        case .backspace:
            let uivalue = UInt(round(value*10000))
            let nvalue = uivalue/10
            if nvalue >= UInt(round(minValue*10000)), nvalue <= UInt(round(maxValue*10000)) {
                value = Double(nvalue)/10000
            }
        case .add(let v):
            let nvalue = value + Double(v)/100
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        case .minus(let v):
            let nvalue = value - Double(v)*100
            if nvalue >= minValue, nvalue <= maxValue {
                value = nvalue
            }
        default: return
        }
    }
}

extension KLPercentField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let _ = Double(string) else { return false }
        return true
    }
}


