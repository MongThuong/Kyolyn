//
//  SplitBillDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/22/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum SplitBillType {
    case count
    case percentage
    case amount
}

/// For splitting a single `Bill` of an `Order`.
class SplitBillDVM: DialogViewModel<Order> {
    /// The editing order
    var order: Order!
    var bill: Bill!
    
    /// Hold the current selected splitting type
    let selectedSplit = BehaviorRelay<(SplitBillType, Double)?>(value: nil)
    
    /// For editing an order.
    ///
    /// - Parameter store: The `Order` to edit.
    init(_ bill: Bill, of order: Order) {
        super.init()
        self.bill = bill
        self.order = order
        
        dialogTitle.accept("Split Bill \(order.bills.index(of: bill)! + 1) (#\(order.orderNo)) - \(bill.total.asMoney)")
        
        selectedSplit
            .asDriver()
            .map { split -> Bool in
                guard let split = split else { return false }
                switch split.0 {
                case .count: return split.1 > 0 && split.1 < 20
                case .percentage: return split.1 > 0 && split.1 < 1
                case .amount: return split.1 > 0 && split.1 < bill.total
                }
            }
            .drive(canSave)
            .disposed(by: disposeBag)
        
        save
            .map { _ -> Order? in
                // Make sure we got the right split request
                guard let (type, value) = self.selectedSplit.value,
                    // Try to find the bill index
                    let billIndex = order.bills.index(of: bill)
                    else { return nil }
                
                let id = UInt64(BaseModel.newID)!
                var bills: [Bill]!
                
                switch type {
                case .count:
                    let total = (bill.total / value).roundM()
                    bills = [UInt64](0..<UInt64(value)).map {
                        bill.split(amount: total, with: "\(id + $0)")
                    }
                    // Compensate the error
                    bills.first?.total += bill.total - total * value
                case .percentage:
                    let splitTotal = (bill.total * value).roundM()
                    bills = [
                        bill.split(amount: splitTotal, with: "\(id)"),
                        bill.split(amount: bill.total - splitTotal, with: "\(id + 1)")
                    ]
                case .amount:
                    bills = [
                        bill.split(amount: value, with: "\(id)"),
                        bill.split(amount: bill.total - value, with: "\(id + 1)")
                    ]
                }
                // Insert the new bills and remove the splitted bill
                order.bills.remove(at: billIndex)
                order.bills.insert(contentsOf: bills, at: billIndex)
                return order
            }
            .filterNil()
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}
