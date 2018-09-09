//
//  PayBillDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// The printing items view model.
class PayBillDVM: DialogViewModel<PayBillInfo> {
    
    var order: Order!
    var bill: Bill!

    var paymentTypes: BehaviorRelay<[PaymentType]>!
    var subPaymentTypes: Driver<[PaymentType]>!
    var selectedPaymentType: BehaviorRelay<PaymentType>!
    var selectedSubPaymentType: BehaviorRelay<PaymentType>!
    let payingAmount = BehaviorRelay<Double>(value: 0.0)
    let tipAmount = BehaviorRelay<Double>(value: 0.0)
    
    /// Init with Order/Bill to pay for.
    ///
    /// - Parameters:
    ///   - order: The `Order` to pay for.
    ///   - bill: The `Bill` to pay for.
    init(_ bill: Bill, of order: Order) {
        super.init()
        
        self.order = order
        self.bill = bill
        
        let billIndex = order.bills.index(of: bill) ?? 0
        dialogTitle.accept("Pay Bill \(billIndex + 1) (#\(order.orderNo))")
        
        let cardPaymentType = CardPaymentType(from: settings)
        let cashPaymentType = CashPaymentType(from: settings)
        paymentTypes = BehaviorRelay(value: [cardPaymentType, cashPaymentType] + settings.paymentTypes)
        // Default to card payment type
        selectedPaymentType = BehaviorRelay(value: cardPaymentType)

        let emptyType = EmptySubPaymentType()
        selectedSubPaymentType = BehaviorRelay(value: emptyType)
        
        subPaymentTypes = selectedPaymentType
            .asDriver()
            .map { [emptyType] + $0.subPaymentTypes }
        
        subPaymentTypes
            .filterEmpty()
            .map { $0.first! }
            .drive(selectedSubPaymentType)
            .disposed(by: disposeBag)
        
        selectedPaymentType
            .asDriver()
            .map { type in
                if let _ = type as? CashPaymentType { return 0.0 }
                else { return bill.total }
            }
            .drive(payingAmount)
            .disposed(by: disposeBag)
        
        payingAmount
            .asObservable()
            .map { $0 > 0 }
            .bind(to: canSave)
            .disposed(by: disposeBag)
        
        save
            .flatMap { _ -> Single<PayBillInfo?> in
                self.order.tip = self.tipAmount.value
                self.bill.tip = self.tipAmount.value
                let type = self.selectedPaymentType.value
                let subType = self.selectedSubPaymentType.value
                let payingAmount = self.payingAmount.value
                let payInfo = (order, bill, type, payingAmount, subType == emptyType ? nil : subType)
                guard type is CashPaymentType else {
                    return Single.just(payInfo)
                }
                // Send command to open cash drawer (dont wait/dont care about error)
                SP.printingService.openCashDrawer()
                // Show dialog to get user confirmation
                return dmodal { CashPromptDVM(max(payingAmount - bill.totalWithTip, 0.0), payInfo: payInfo) }
            }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}


