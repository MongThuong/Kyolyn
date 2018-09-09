//
//  DataService+Order.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension DataService {
    
    /// Save an Order
    ///
    /// - Parameter order: the Order to save.
    /// - Returns: Single of the result.
    func save(order: Order) -> Single<Order?> {
        order.updatedAt = BaseModel.timestamp
        order.updatedBy = id?.employee.id ?? ""

        if self.isMain {
            return self.db.async {
                try self.db.save(order)
                SP.dataService.localOrderChanged.on(.next([order.id]))
                return order
            }
        } else {
            return restClient.save(order: order)
                .map { revision in
                    guard let rev = revision, rev.isNotEmpty else {
                        return nil
                    }
                    order.revision = rev
                    return order
            }
        }
    }
    
    /// Delete an Order.
    ///
    /// - Parameter order: the Order to be deleted.
    /// - Returns: Single of deletion result.
    func delete(order: Order) -> Single<()> {
        order.updatedAt = BaseModel.timestamp
        order.updatedBy = id?.employee.id ?? ""

        if self.isMain {
            return self.db.async {
                try self.db.delete(order)
                SP.dataService.localOrderChanged.on(.next([order.id]))
                return ()
            }
        } else {
            return restClient.delete(order: order)
        }
    }
    
    /// Saved the mering order and delete the merged orders in batch.
    ///
    /// - Parameters:
    ///   - order: the target Order.
    ///   - orders: the merged Orders.
    /// - Returns: Single of the unlocking result
    func merge(order: Order, from orders: [Order]) -> Single<Order?> {
        if self.isMain {
            return self.db.async {
                try self.db.runBatch {
                    try self.db.save(order)
                    try self.db.delete(multi: orders)
                    SP.dataService.localOrderChanged.on(.next([order.id] + orders.map { $0.id }))
                }
                return order
            }
        } else {
            return restClient.merge(order: order, from: orders.map { $0.id })
                .map { success in success ? order: nil }
        }
    }
        
    /// Increase order's no.
    ///
    /// - Parameter order: the order.
    /// - Returns: Single of the setting new order result.
    func set(newOrderNo order: Order) -> Single<Order?> {
        guard order.orderNo == 0 else {
            return Single.just(order)
        }
        return self
            .increase(counter: .orderNo)
            .map { shift -> Order? in
                guard let shift = shift else {
                    return nil
                }
                order.orderNo = shift.orderNum
                return order
        }
    }
    
    /// Load opening orders for given Area.
    ///
    /// - Parameters:
    ///   - area: the area to load for.
    ///   - filter: the filter to be applied
    /// - Returns: Single of the loading result.
    func load(openingOrders area: Area? = nil, withFilter filter: String = "PENDING") -> Single<[Order]> {
        guard let shiftID = self.activeShift.value?.id else {
            return Single.just([])
        }
        if self.isMain {
            return self.db.async {
                self.db.load(openingOrders: self.store.id, forShift: shiftID, inArea: area, withFilter: filter)
            }
        } else {
            return restClient.load(openingOrders: shiftID, inArea: area, withFilter: filter)
        }
    }
    
    /// Load orders of current Store and Shift
    ///
    /// - Parameters:
    ///   - statuses: the filter statuses.
    ///   - page: the page to load for.
    ///   - pageSize: the page size to load for.
    /// - Returns: Single of the loading result.
    func load(orders statuses: [OrderStatus], page: UInt, pageSize: UInt) -> Single<QueryResult<Order>> {
        guard  let shiftID = activeShift.value?.id else {
            return Single.just(QueryResult())
        }
        if self.isMain {
            return self.db.async {
                self.db.load(orders: self.store.id, forShift: shiftID, matchingStatuses: statuses, page: page, pageSize: pageSize)
            }
        } else {
            return restClient.load(orders: shiftID, statuses: statuses, page: page, pageSize: pageSize)
        }
    }
}
