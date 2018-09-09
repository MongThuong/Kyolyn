//
//  TableViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias TableState = ([Order], [String: String], TableViewModel?, (MovingModeType, Order)?)

/// Holding logic of a single table.
class TableViewModel: NSObject {
    let disposeBag = DisposeBag()
    /// Hold the table detail.
    let table: Table
    /// Hold the area the detail.
    let area: Area
    /// Hold the info about the orders in this table.
    let orders = BehaviorRelay<[Order]>(value: [])
    /// The inputs that will effect the state of button
    var tableState: Driver<TableState>!

    init(_ table: Table, in area: Area, root vm: TablesLayoutViewModel) {
        self.table = table
        self.area = area
        tableState = Driver
            .combineLatest(
                orders.asDriver(),
                vm.dataService.lockedOrders.asDriver(),
                vm.selectedTable.asDriver(),
                vm.selectedOrder.asDriver()
            ) { ($0, $1, $2, $3) }
    }

    override var description: String {
        return "\(area.name)/\(table.name)"
    }
}

