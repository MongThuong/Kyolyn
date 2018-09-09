//
//  EditSubPaymentDVM.swift
//  Kiolyn
//
//  Created by TienPham on 10/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// The printing items view model.
class EditSubPaymentDVM: DialogViewModel<Transaction> {
    let transaction: Transaction
    var bill: Bill!
    // Payment Type
    var paymentType: BehaviorRelay<PaymentType>!
    // Sub Payment Types
    var subPaymentTypes: Driver<[PaymentType]>!
    var subPaymentType: BehaviorRelay<PaymentType>!
    
    // Publish to select sub
    let selectSubPaymentType = PublishSubject<PaymentType>()
    
    init(_ transaction: Transaction) {
        self.transaction = transaction
        super.init()
        
        dialogTitle.accept("Select Sub Payment Types")
        let cardPaymentType = CardPaymentType(from: settings)
        let cashPaymentType = CashPaymentType(from: settings)
        let emptyType = EmptySubPaymentType()

        if transaction.transType == .cash {
            paymentType = BehaviorRelay(value: cashPaymentType)
        } else if transaction.transType == .creditSale {
            paymentType = BehaviorRelay(value: cardPaymentType)
        } else {
            let transPaymentType = settings.paymentTypes
                .filter {$0.id == transaction.customTransType}
                .first!
            paymentType = BehaviorRelay(value: transPaymentType)
        }
        
        let transSubPaymentType = paymentType.value.subPaymentTypes
            .filter { $0.id == transaction.subPaymentType }
            .first
        if transSubPaymentType != nil {
            subPaymentType = BehaviorRelay(value: transSubPaymentType!)
        } else {
            subPaymentType = BehaviorRelay(value: emptyType)
        }

        subPaymentTypes = paymentType
            .asDriver()
            .map { $0.subPaymentTypes }
        
        selectSubPaymentType
            .map { subPaymentType -> Transaction in
                var spt: PaymentType? = subPaymentType
                if spt is EmptySubPaymentType {
                    spt = nil
                }
                return self.transaction.set(subPaymentType: spt)
            }
            .save()
            .catchError { error -> Observable<Transaction> in
                derror(error)
                return Observable.empty()
            }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}
