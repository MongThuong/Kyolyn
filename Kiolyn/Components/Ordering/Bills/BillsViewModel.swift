//
//  BillsViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

extension Notification.Name {
    static let klBillsMovingModeChanged = Notification.Name("klBillsMovingModeChanged")
}

/// For handling Order's Bills related business
class BillsViewModel: BaseViewModel {
    /// The list of bills to work on.
    let bills = BehaviorRelay<[BillViewModel]>(value: [])
    
    let reset = PublishSubject<Void>()
    let addBill = PublishSubject<Void>()
    let printAll = PublishSubject<Void>()
    
    /// Hold the current selected bill for tap-tap
    let movingBill = BehaviorRelay<Bill?>(value: nil)
    let selectBillItem = PublishSubject<(Bill, OrderItem)>()
    let moveSelectedItemsTo = PublishSubject<Bill?>()
    
    /// Create with service provider
    ///
    /// - Parameter provider: Service provider.
    override init() {
        super.init()
        // Update bills when Order changed, 'changed' is not necessarily changing to new order
        // but whenever the order got saved, this will be called, we need to prevent the unnessary reloading here, especially when adding OrderItem
        orderManager.order
            .asDriver()
            .map { order in
                guard let order = order else {
                    return []
                }
                return order.bills.map {
                    BillViewModel($0, of: order, for: self)
                }
            }
            .drive(bills)
            .disposed(by: disposeBag)
                
        reset
            .modify(currentOrder: "resetBills") { order in
                Single.just(order.resetBills())
            }
            .subscribe()
            .disposed(by: disposeBag)
        addBill
            .modify(currentOrder: "addBill") { order in
                Single.just(order.addBill())
            }
            .subscribe()
            .disposed(by: disposeBag)

        printAll
            .modify(currentOrder: "printAllChecks") { order -> Single<Order?> in
                dmodal { PrintBillDVM(of: order, type: .check) }
                    .map { args -> Order? in
                        guard let (order, _) = args else {
                            return nil
                        }
                        return order.check(bill: nil)
                    }
            }
            .subscribe()
            .disposed(by: disposeBag)

        selectBillItem
            .map { (bill, billItem) in self.create(movingBillFrom: bill, forItem: billItem) }
            .bind(to: movingBill)
            .disposed(by: disposeBag)

        moveSelectedItemsTo
            .modify(currentOrder: "moveItemToNewBill") { (toBill, order) -> Single<(Bill?, Order)?> in
                // has valid moving bill
                guard let movingBill = self.movingBill.value, movingBill.items.isNotEmpty,
                    // which exist in current order
                    let fromBill = order.bills.first(where: { $0.id == movingBill.id }),
                    // update OK
                    let order = order.move(items: movingBill.items, from: fromBill, to: toBill)
                    else {
                        return Single.just(nil)
                }
                return Single.just((toBill, order))
            }
            .map { _ -> Bill? in nil }
            .bind(to: movingBill)
            .disposed(by: disposeBag)

        // Notify OrderDetailView
        movingBill
            .asDriver()
            .drive(onNext: { movingBill in
                var info: [String:Any] = [:]
                if let movingBill = movingBill {
                    info["movingBill"] = movingBill
                }
                NotificationCenter.default.post(name: .klBillsMovingModeChanged, object: self, userInfo: info)
            })
            .disposed(by: disposeBag)
    }
    
    /// Create a moving bill from a source bill and order item.
    ///
    /// - Parameters:
    ///   - fromBill: the source bill.
    ///   - orderItem: the order item to be moved.
    /// - Returns: the bill or empty
    private func create(movingBillFrom bill: Bill, forItem billItem: OrderItem) -> Bill? {
        guard let order = orderManager.order.value else {
            return nil
        }
        // Get the current moving bill
        var movingBill = self.movingBill.value
        
        // If no bill is created yet, create one
        if movingBill == nil {
            movingBill = Bill(order: order)
            movingBill?.id = bill.id
        } else {
            // Otherwise make sure it is the same bill
            guard movingBill?.id == bill.id else { return nil }
        }
        
        if let existingItem = movingBill?.items.first(where: { $0.id == billItem.id }) {
            guard existingItem.count < billItem.count else { return nil }
            existingItem.count += 1
            existingItem.updateCalculatedValues()
        } else {
            let newItem: OrderItem = billItem.clone()
            newItem.count = 1
            newItem.updateCalculatedValues()
            movingBill?.items.append(newItem)
        }
        
        movingBill?.updateCalculatedValues()
        return movingBill
    }
}
