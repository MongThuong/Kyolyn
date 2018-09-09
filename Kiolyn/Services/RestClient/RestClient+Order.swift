//
//  RestClient+Order.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension RestClient {
    
    /// Load opening Order from Main in the given shift with the optional area (null for all areas) and optional filter (PENDING by default).
    ///
    /// - Parameters:
    ///   - shift: the shift to load for.
    ///   - area: the area to load for.
    ///   - filter: the filter to load for.
    /// - Returns: Single of the opening Order(s).
    func load(openingOrders shiftID: String, inArea area: Area? = nil, withFilter filter: String = "PENDING") -> Single<[Order]> {
        guard let storeID = store?.id else {
            return Single.just([])
        }
        let params = ["shiftid": shiftID, "areaid": area?.id ?? "", "filter": filter]
        return load(multiModel: "store/\(storeID)/order/opening", params: params)
    }
    
    /// Delete Order from Main.
    ///
    /// - Parameter order: the Order to be deleted.
    func delete(order: Order) -> Single<()> {
        guard let storeID = store?.id else {
            return Single.just(())
        }
        return delete(model: "store/\(storeID)/order/\(order.id)")
    }
    
    /// Save Order to Main.
    ///
    /// - Parameter order: the Order to be saved.
    /// - Returns: Single of the new revision
    func save(order: Order) -> Single<String?> {
        guard let storeID = store?.id else {
            return Single.just(nil)
        }
        return post(path: "store/\(storeID)/order", data: order.toJSON())
    }
    
    /// Load Order(s) by status with support for pagination.
    ///
    /// - Parameters:
    ///   - shift: the Shift to load for.
    ///   - status: the status of the Order to filter for.
    ///   - page: the current page to load for.
    ///   - pageSize: the number of order to load for.
    /// - Returns: Single of the QueryResult.
    func load(orders shiftID: String, statuses: [OrderStatus], page: UInt, pageSize: UInt) -> Single<QueryResult<Order>> {
        guard let storeID = store?.id else {
            return Single.just(QueryResult())
        }
        let status = statuses.first?.rawValue ?? ""
        let params: [String: Any] = ["shiftid": shiftID, "status": status, "page": page, "pagecount": pageSize]
        return query(model: "store/\(storeID)/order", params: params)
    }
    
    /// Merge the given order ids into the final merged order.
    ///
    /// - Parameters:
    ///   - mergedOrder: the final merging Order.
    ///   - orders: the list of merged orders' ids.
    /// - Returns: Single of the result.
    func merge(order mergedOrder: Order, from orders: [String]) -> Single<Bool> {
        guard let storeID = store?.id else {
            return Single.just(false)
        }
        let data: [String: Any] = [
            "final_order": mergedOrder.toJSON(),
            "from_orders": orders,
            "orders": [mergedOrder.id] + orders
        ]
        let request: Single<String?> = post(path: "store/\(storeID)/order/merge", data: data)
        return request.map { rev in rev?.isNotEmpty ?? false }
    }
 }
