//
//  AreaViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Holding logic of an area.
class AreaViewModel: NSObject {
    let theme = Theme.mainTheme
    let disposeBag = DisposeBag()

    let area: Area
    let tables = BehaviorRelay<[TableViewModel]>(value: [])
    let orders = BehaviorRelay<[Order]>(value: [])
    
    /// Contains the area detail, should include Area name plus the number of orders and total table.
    var areaDetail: Driver<String>!

    init(_ area: Area, root vm: TablesLayoutViewModel) {
        self.area = area
        let tw = theme.standardTableWidth
        let th = theme.standardTableHeight
        let gl = theme.guideline/2
        if area.isAutoIncrement {
            orders
                .asDriver()
                .map { orders in
                    orders.enumerated().map{ (i, order) -> TableViewModel in
                        let table = Table(id: order.id)
                        table.name = "\(area.name) #\(order.orderNo)"
                        table.width = tw
                        table.height = th
                        table.left = gl + tw/2
                        table.top = CGFloat(i) * (th + gl) + th/2 + gl
                        let tableVM = TableViewModel(table, in: area, root: vm)
                        tableVM.orders.accept([order])
                        return tableVM
                    }
                }
                .drive(tables)
                .disposed(by: disposeBag)
            areaDetail = orders
                .asDriver()
                .map { orders in "\(area.name) (\(orders.count))" }
        } else {
            // Single time setup
            tables.accept(area.tables.map { TableViewModel($0, in: area, root: vm) })
            // Watch for orders changes.
            areaDetail = Driver
                .combineLatest(
                    tables.asDriver(),
                    orders.asDriver())
                .filter { (tables, orders) -> Bool in
                    // Allocate orders to its corresponding area/table
                    for t in tables {
                        t.orders.accept(orders.filter { $0.table == t.table.id })
                    }
                    return true
                }
                .map { (tables, orders) in "\(area.name) (\(orders.count)/\(tables.count))" }            
        }
    }
    
    func reload(orders filter: DeliveredFilter) {
        _ = SP.dataService
            .load(openingOrders: area, withFilter: filter.rawValue)
            .asObservable()
            .bind(to: orders)
    }
}

