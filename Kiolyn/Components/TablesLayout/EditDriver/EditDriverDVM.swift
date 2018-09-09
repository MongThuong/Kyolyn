//
//  EditDriverDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 10/19/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Edit Driver.
class EditDriverDVM: SelectItemDVM<Employee> {
    let order: Order
    
    lazy var noDriver: Employee = {
        return try! Employee.noDriver()
    }()
    
    init(_ order: Order) {
        self.order = order
        super.init()
        dialogTitle.accept("Edit Driver #\(order.orderNo)")
        closeDialog
            .subscribe(onNext: { e in
                guard let emp = e else { return }
                if emp.id == "no" {
                    _ = self.order.set(driver: nil)
                } else {
                    _ = self.order.set(driver: emp)
                }
            })
            .disposed(by: disposeBag)
    }

    override func loadData() -> Single<[Employee]> {
        return dataService.loadAllDrivers()
            .map { drivers in drivers + [self.noDriver] }
    }
}
