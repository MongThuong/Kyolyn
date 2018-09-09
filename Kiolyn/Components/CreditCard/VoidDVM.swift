//
//  CreditVoidDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

class CreditVoidDVM: CreditCardDVM {
    private let trans: Transaction
    private let reason: String
    init(_ ccDevice: CCDevice, for trans: Transaction, with reason: String) {
        self.trans = trans
        self.reason = reason
        super.init(ccDevice)
        dialogTitle.accept("Void Trans #\(trans.transNum)")
    }

    override func sendRequest() -> Observable<CCStatus> {
        return SP.ccService.void(trans: trans.refNum, using: device.value, byEmployee: employee)
    }
    
    override func create(transaction result: CCResult, forShift shift: Shift) throws -> Transaction {
        return trans // Just return itself, the caller will do the rest of the work
    }
}
