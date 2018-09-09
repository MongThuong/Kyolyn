//
//  ServiceFeeButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/11/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Type of service fee.
enum ServiceFeeType {
    case amount
    case percentage
}

/// For selecting payment type/sub payment type in Payment Dialog.
class ServiceFeeButton: KLRaisedButton {
//    let disposeBag = DisposeBag()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: theme.largeButtonHeight, height: theme.largeButtonHeight)
    }

    override func prepare() {
        super.prepare()
        borderColor = theme.primary.lighten1
        layer.borderWidth = 1.0
        titleLabel?.font = theme.smallFont
    }

    var value: (ServiceFeeType, Double)?

    static func new(value: (ServiceFeeType, Double), with theme: Theme) -> ServiceFeeButton {
        let button = ServiceFeeButton(theme)
        button.value = value
        switch value.0 {
        case .percentage:
            button.title = "\(value.1.asPercentage)"
        case .amount:
            button.title = "\(value.1.asRoundedMoney)"
        }
        return button
    }
}

