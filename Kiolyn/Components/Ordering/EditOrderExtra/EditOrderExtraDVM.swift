//
//  EditOrderExtraDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/17/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EditOrderExtraDVM: DialogViewModel<Order> {
    let order: Order
    let initialTabIndex: Int
    
    var selectedTax: BehaviorRelay<(Tax, Employee?)>!
    var selectedDiscount: BehaviorRelay<Discount>!
    var discountAdjustedPercent: BehaviorRelay<Double>!
    var discountAdjustedReason: BehaviorRelay<String?>!
    let selectDiscountReason = PublishSubject<Void>()
    var discountReasonSelected: Driver<String>!
    
    var ggPercent: BehaviorRelay<Double>!
    var ggReason: BehaviorRelay<String?>!
    let selectGGReason = PublishSubject<Void>()
    var ggReasonSelected: Driver<String>!
    
    var sfAmount: BehaviorRelay<Double>!
    var sfPercent: BehaviorRelay<Double>!
    
    let changeTax = PublishSubject<Tax>()

    init(_ order: Order, showTab initialTab: Int = 0) {
        self.order = order
        self.initialTabIndex = initialTab

        super.init()
        
        let gg = self.settings.find(groupGratuity: order.persons)
        
        selectedTax = BehaviorRelay<(Tax, Employee?)>(value: (order.tax, nil))
        selectedDiscount = BehaviorRelay<Discount>(value: order.discount)
        discountAdjustedPercent = BehaviorRelay<Double>(value: order.discount.adjustedPercent)
        discountAdjustedReason = BehaviorRelay<String?>(value: order.discount.adjustedReason)
        ggPercent = BehaviorRelay<Double>(value: order.serviceFee)
        ggReason = BehaviorRelay<String?>(value: order.serviceFeeReason)

        if order.customServiceFeePercent > 0 {
            sfAmount = BehaviorRelay<Double>(value: 0)
            sfPercent = BehaviorRelay<Double>(value: order.customServiceFeePercent)
        } else {
            sfAmount = BehaviorRelay<Double>(value: order.customServiceFeeAmount)
            sfPercent = BehaviorRelay<Double>(value: 0)
        }

        Observable
            .merge(
                selectedDiscount.asObservable().mapToVoid(),
                discountAdjustedPercent.asObservable().mapToVoid(),
                discountAdjustedReason.asObservable().mapToVoid(),
                ggPercent.asObservable().mapToVoid(),
                ggReason.asObservable().mapToVoid()
            )
            .map { _ in
                // Check for discount reason
                let discount = self.selectedDiscount.value
                if discount.percent > 0 && discount.percent != self.discountAdjustedPercent.value {
                    guard let reason = self.discountAdjustedReason.value, reason.isNotEmpty else {
                        return false
                    }
                }
                // Check for gg reason
                if let gg = gg, gg.percent != self.ggPercent.value {
                    guard let reason = self.ggReason.value, reason.isNotEmpty else {
                        return false
                    }
                }
                return true
            }
            .bind(to: canSave)
            .disposed(by: disposeBag)

        discountReasonSelected = selectDiscountReason
            .modal { SelectAndEditReasonDVM(self.settings.discountReasons) }
            .asDriver(onErrorJustReturn: "")
        discountReasonSelected
            .drive(discountAdjustedReason)
            .disposed(by: disposeBag)

        ggReasonSelected = selectGGReason
            .modal { SelectAndEditReasonDVM(self.settings.voidGroupGratuityReasons) }
            .asDriver(onErrorJustReturn: "")
        ggReasonSelected
            .drive(ggReason)
            .disposed(by: disposeBag)
        
        changeTax
            .filter { tax -> Bool in
                // Do nothing if new tax is the same with current tax
                self.selectedTax.value.0.id != tax.id
            }
            .flatMap { tax -> Single<(Tax, Employee?)> in
                // adding tax is safe, no need to check for permission
                if tax.id != Tax.noTaxID {
                    return Single.just((tax, self.employee))
                }
                return require(permission: Permissions.CHANGE_ORDER_TAX).map { emp in (tax, emp) }
            }
            .filter { (_, emp) in emp != nil }
            .bind(to: selectedTax)
            .disposed(by: disposeBag)

        save
            .map { _ -> Order in
                let order = self.order
                // TAX
                let (tax, employee) = self.selectedTax.value
                if tax.id == Tax.noTaxID {
                    order.tax = Tax.noTax
                    order.taxRemovedBy = employee?.id ?? ""
                } else {
                    order.tax = tax.clone()
                }
                // DISCOUNT
                let discount = self.selectedDiscount.value
                order.discount = discount.clone()
                order.discount.adjustedPercent = self.discountAdjustedPercent.value
                order.discount.adjustedReason = self.discountAdjustedReason.value ?? ""
                // GROUP GRATUITY
                order.serviceFee = self.ggPercent.value
                order.serviceFeeTax = self.settings.groupGratuityTax
                order.serviceFeeReason = self.ggReason.value ?? ""
                // SERVICE FEE
                order.customServiceFeePercent = self.sfPercent.value
                order.customServiceFeeAmount = self.sfAmount.value
                // UPDATE BILLS
                for bill in order.bills.filter({ bill in bill.isNotPaid }) {
                    bill.tax = order.tax.clone()
                    bill.discount = order.discount.clone()
                    bill.serviceFee = order.serviceFee
                    bill.serviceFeeTax = order.serviceFeeTax
                    bill.customServiceFeePercent = order.customServiceFeePercent
                    bill.customServiceFeeAmount = order.customServiceFeeAmount
                    bill.updateCalculatedValues()
                }
                return order
            }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}

