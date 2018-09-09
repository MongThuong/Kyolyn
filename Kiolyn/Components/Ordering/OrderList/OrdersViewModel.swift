//
//  OrdersViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For handling Orders list related business.
class OrdersViewModel: CommonDataTableViewModel<Order> {
    
    var statuses = BehaviorRelay<[OrderStatus]>(value: [
        OrderStatus.new,
        OrderStatus.submitted,
        OrderStatus.printed,
        OrderStatus.checked,
        OrderStatus.voided
    ])
    var selectedStatuses = BehaviorRelay<[OrderStatus]>(value: [])
    var selectStatus = PublishSubject<OrderStatus>()    
    
    override init() {
        super.init()
        
        // A status is selected, we need to update selected status and reload
        selectStatus
            .map { status in
                self.selectedStatuses.value.contains(status) ? [] : [status]
//                var statuses = self.selectedStatuses.value
//                if let idx = statuses.index(of: status) {
//                    statuses.remove(at: idx)
//                } else {
//                    statuses.append(status)
//                }
//                return statuses
            }
            .bind(to: selectedStatuses)
            .disposed(by: disposeBag)

        // Reload on filter changed
        selectedStatuses
            .asObservable()
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                guard lhs.count == rhs.count else { return false }
                for (idx, l) in lhs.enumerated() {
                    guard rhs[idx] == l else { return false }
                }
                return true
            }
            .mapToVoid()
            .bind(to: reload)
            .disposed(by: disposeBag)

        // Update the current editing order upon user selection
        selectedRow
            .asObservable()
            .filterNil()
            .setCurrent()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    override func loadData() -> Single<QueryResult<Order>> {
        return dataService.load(orders: selectedStatuses.value, page: page.value, pageSize: pageSize.value)
    }
}
