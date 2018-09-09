//
//  CashPromptDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For prompting CASH change information.
class CashPromptDVM: DialogViewModel<PayBillInfo> {
    var changeAmount: Double!
    var payInfo: PayBillInfo!
    init(_ changeAmount: Double, payInfo: PayBillInfo) {
        self.changeAmount = changeAmount
        self.payInfo = payInfo
        super.init()
    }
}
