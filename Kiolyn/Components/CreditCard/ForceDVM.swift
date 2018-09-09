//
//  ForceDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For getting Force inputs.
class ForceDVM: DialogViewModel<(Double, String)> {
    let amount = BehaviorRelay<Double>(value: 0)
    let authCode = BehaviorRelay<String>(value: "")
    
    override init() {
        super.init()
        dialogTitle.accept("Force")
        
        let inputs = Driver
            .combineLatest(
                amount.asDriver(),
                authCode.asDriver()
            ) { (amount, authCode) in (amount, authCode) }
        
        inputs
            .map { (amount, authCode) -> Bool in
                amount > 0 && authCode.isNotEmpty
            }
            .drive(canSave)
            .disposed(by: disposeBag)
        
        save.withLatestFrom(inputs)
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}

class CreditForceDVM: CreditCardDVM {
    private let amount: Double
    private let authCode: String
    
    override var requireNewTransNo: Bool {
        return true
    }
    
    init(_ ccDevice: CCDevice, amount: Double, authCode: String) {
        self.amount = amount
        self.authCode = authCode
        super.init(ccDevice)
        dialogTitle.accept("Force \(amount.asMoney)")
    }
    
    override func sendRequest() -> Observable<CCStatus> {
        return SP.ccService.force(amount: amount, using: device.value, byEmployee: employee, with: authCode)
    }
    
    override func create(transaction result: CCResult, forShift shift: Shift) throws -> Transaction {
        guard let result = result as? PaymentResult else {
            throw CCError.invalidReponse(detail: "Expecting Payment Result")
        }
        return Transaction(forForce: store, forShift: shift, byEmployee: employee, ccDevice: self.device.value, result: result)
    }
}
