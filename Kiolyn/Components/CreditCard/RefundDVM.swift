//
//  RefundDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For getting Refund inputs.
class RefundDVM: DialogViewModel<Double> {
    let amount = BehaviorRelay<Double>(value: 0)
    
    override var dialogResult: Double? {
        return amount.value
    }
    
    override init() {
        super.init()
        dialogTitle.accept("Refund")
        
        amount
            .asDriver()
            .map { $0 > 0 }
            .drive(canSave)
            .disposed(by: disposeBag)
        
        save.withLatestFrom(amount)
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}

class CreditRefundDVM: CreditCardDVM {
    let amount: Double
    
    override var requireNewTransNo: Bool {
        return true
    }
    
    init(_ ccDevice: CCDevice, amount: Double) {
        self.amount = amount
        super.init(ccDevice)
        dialogTitle.accept("Refund \(amount.asMoney)")
    }
    
    override func sendRequest() -> Observable<CCStatus> {
        return SP.ccService.refund(amount: amount, using: device.value, byEmployee: employee)
    }
    
    override func create(transaction result: CCResult, forShift shift: Shift) throws -> Transaction {
        guard let result = result as? PaymentResult else {
            throw CCError.invalidReponse(detail: "Expecting Payment Result")
        }
        return Transaction(forRefund: store, forShift: shift, byEmployee: employee, ccDevice: self.device.value, result: result)
    }
}
