//
//  AdjustTipTextField+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/21/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FontAwesomeKit

extension Reactive where Base : AdjustTipField {
    /// Reactive wrapper for `status` property.
    var status: ControlProperty<ViewStatus> {
        return base.rx.controlProperty(
            editingEvents: [.valueChanged],
            getter: { _ in .none },
            setter: { tipField, status in
                switch status {
                case .loading:
                    tipField.adjusting = true
                    tipField.loading.isHidden = false
                    tipField.loading.startAnimating()
                    tipField.status.isHidden = true
                    tipField.isEnabled = false
                case .ok:
                    tipField.adjusting = false
                    tipField.loading.isHidden = true
                    tipField.loading.stopAnimating()
                    tipField.status.isHidden = false
                    tipField.status.textColor = .white
                    tipField.status.fakIcon = FAKFontAwesome.checkIcon(withSize: 14.0)
                    tipField.isEnabled = true
                case .error(_):
                    tipField.adjusting = false
                    tipField.loading.isHidden = true
                    tipField.loading.stopAnimating()
                    tipField.status.isHidden = false
                    tipField.status.textColor = tipField.theme.warn.base
                    tipField.status.fakIcon = FAKFontAwesome.exclamationTriangleIcon(withSize: 14.0)
                    tipField.isEnabled = true
                default: return
                }
        })
    }
}
