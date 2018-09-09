//
//  EditOrderDialogViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/12/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EditOrderDVM: EditCustomerDVM {
    let area = BehaviorRelay<Area?>(value: nil)
    let guests = BehaviorRelay<UInt>(value: 1)
    var shouldClearInFirstTime: Bool = false

    override init(_ order: Order) {
        super.init(order)

        dialogTitle.accept("Order #\(order.orderNo)")

        dialogDidAppear
            .flatMap { self.dataService.load(order.area) }
            .bind(to: area)
            .disposed(by: disposeBag)
        
        guests.accept(order.persons)
        guests
            .asDriver()
            .map { $0 > 0 }
            .drive(canSave)
            .disposed(by: disposeBag)
    }
    
    convenience init(_ order: Order, _ clearInFistTime: Bool) {
        self.init(order)
        shouldClearInFirstTime = clearInFistTime
    }
    
    override func save() -> Single<Order?> {
        return super.save()
            .map { ord in
                guard let order = ord, order.persons != self.guests.value else {
                    return ord
                }
                order.persons = self.guests.value
                if let gg = self.settings.find(groupGratuity: order.persons) {
                    order.serviceFee = gg.percent
                    order.serviceFeeReason = ""
                } else {
                    order.serviceFee = 0
                    order.serviceFeeReason = ""
                }
                return order
        }
    }
}
