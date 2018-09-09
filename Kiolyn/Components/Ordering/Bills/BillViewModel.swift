//
//  BillViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For handling single Bill related business.
class BillViewModel: BaseViewModel {
    /// The parent bill list.
    let billList: BillsViewModel
    /// The `Bill`.
    let bill: Bill
    let order: Order
    /// The `Transaction` that might be used for paying this bill.
    let transaction = BehaviorRelay<Transaction?>(value: nil)
    
    let split = PublishSubject<Void>()
    let remove = PublishSubject<Void>()
    let pay = PublishSubject<Void>()
    let canPrint = BehaviorRelay<Bool>(value: false)
    let print = PublishSubject<Void>()
    let printCheck = PublishSubject<Void>()
    let printReceipt = PublishSubject<Void>()
    let void = PublishSubject<Void>()
    let selectBillItem = PublishSubject<OrderItem>()
    let moveSelectedItemsToThisBill = PublishSubject<Void>()
    
    init(_ bill: Bill, of order: Order, for list: BillsViewModel) {
        self.billList = list
        self.bill = bill
        self.order = order
        super.init()

        if bill.transaction.isNotEmpty {
            _ = dataService
                .load(bill.transaction)
                .asDriver(onErrorJustReturn: nil)
                .drive(transaction)
        }
        
        remove
            .modify(currentOrder: "removeBill") { order in
                Single.just(order.remove(bill: bill))
            }
            .filterNil()
            // Show menu if there is no bill left
            .filter { order in order.noBills }
            .show(ordering: .menu)
            .disposed(by: disposeBag)
        split
            .modify(currentOrder: "splitBill") { order -> DialogViewModel<Order> in
                SplitBillDVM(bill, of: order)
            }
            .subscribe()
            .disposed(by: disposeBag)
        pay.modify(currentOrder: "payBill") { order -> Single<Order?> in
                dmodal { PayBillDVM(bill, of: order) }
                    .flatMap { payBillInfo in
                        guard let pbi = payBillInfo else {
                            return Single.just(nil)
                        }
                        return Kiolyn.pay(bill: pbi)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
        print
            .modify(currentOrder: "printCheck") { order -> Single<Order?> in
                dmodal { PrintBillDVM(bill: bill, of: order, type: .check) }
                    .map { args -> Order? in
                        guard let (order, bill) = args else {
                            return nil
                        }
                        return order.check(bill: bill)
                    }
            }
            .subscribe()
            .disposed(by: disposeBag)
        void
            .flatMap { require(permission: Permissions.REFUND_VOID_UNPAID_SETTLE) }
            .filterNil()
            .withLatestFrom(transaction)
            .filterNil()
            .flatMap { trans in Kiolyn.void(transaction: trans, withOrder: order) }
            .modify(currentOrder: "reloadAfterVoid") { order -> Single<Order?> in
                self.dataService.load(order.id)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        printCheck
            .flatMap { dmodal { PrintBillDVM(bill: bill, of: order, type: .check) } }
            .subscribe()
            .disposed(by: disposeBag)
        printReceipt
            .flatMap { dmodal { PrintBillDVM(bill: bill, of: order, type: .receipt) } }
            .subscribe()
            .disposed(by: disposeBag)
        selectBillItem
            .map { orderItem -> (Bill, OrderItem)? in
                guard bill.isNotPaid else {
                    dinfo("Bill is paid, moving item is not allowed.")
                    return nil
                }
                guard bill.isNotSplitted else {
                    dinfo("Bill is not whole, moving item is not allowed.")
                    return nil
                }
                return (bill, orderItem)
            }
            .filterNil()
            .bind(to: billList.selectBillItem)
            .disposed(by: disposeBag)
        moveSelectedItemsToThisBill
            .map { bill }
            .filter { $0.isNotPaid && $0.isNotSplitted }
            .bind(to: billList.moveSelectedItemsTo)
            .disposed(by: disposeBag)
    }
}
