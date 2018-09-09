//
//  SaleDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

class CreditSaleDVM: CreditCardDVM {
    private let order: Order
    private let bill: Bill
    private let amount: Double
    private let subType: PaymentType?
    
    override var requireNewTransNo: Bool {
        return true
    }

    init(_ ccDevice: CCDevice, order: Order, bill: Bill, amount: Double, subPaymentType: PaymentType?) {
        self.order = order
        self.bill = bill
        self.amount = amount
        self.subType = subPaymentType
        super.init(ccDevice)
        dialogTitle.accept("Amount Due \(amount.asMoney)")
    }
    
    override func sendRequest() -> Observable<CCStatus> {
        return SP.ccService.sale(amount: amount, using: device.value, byEmployee: employee)
    }
    
    override func create(transaction result: CCResult, forShift shift: Shift) throws -> Transaction {
        guard let result = result as? PaymentResult else {
            throw CCError.invalidReponse(detail: "Expecting Payment Result")
        }
        return Transaction(forCard: store, forShift: shift, byEmployee: employee, ccDevice: device.value, order: order, bill: bill, result: result, subPaymentType: subType)
    }
}
