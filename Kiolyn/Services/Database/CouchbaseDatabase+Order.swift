//
//  CouchbaseDatabase+Order.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension CouchbaseDatabase {
    
    /// Group orders by store/shift/status
    var orderByOrderNoView: CBLView {
        // Get/Create view
        let view = database.viewNamed("order_by_no")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Order.documentType,
                    let id = doc["id"] as? String, id.count > 6 ,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let status = doc["status"] as? String, status.isNotEmpty,
                    let shiftID = doc["shift_id"] as? String, shiftID.isNotEmpty else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                let orderNo = (doc["order_no"] as? Int) ?? 0
                emit([storeID, shiftID, orderNo], nil)
        }, reduce: totalReduce, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    /// Group orders by store/shift/status
    var orderByOrderStatusView: CBLView {
        // Get/Create view
        let view = database.viewNamed("order_by_status")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Order.documentType,
                    let id = doc["id"] as? String, id.count > 6 ,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let status = doc["status"] as? String, status.isNotEmpty,
                    let shiftID = doc["shift_id"] as? String, shiftID.isNotEmpty else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, shiftID, status], nil)
        }, reduce: totalReduce, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    /// Group orders by store/shift/status
    var orderByShiftAreaDriverView: CBLView {
        // Get/Create view
        let view = database.viewNamed("order_by_shift_area_driver")
        view.setMapBlock({ (doc, emit) in
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == Order.documentType,
                let id = doc["id"] as? String, id.count > 6 ,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                let statusValue = doc["status"] as? String, statusValue.isNotEmpty,
                let status = OrderStatus(rawValue: statusValue), status == .checked,
                let shift = doc["shift"] as? Int, shift > 0,
                let area = doc["area"] as? String, area.isNotEmpty,
                let bills = doc["bills"] as? [[String:Any]]
                else { return }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            // Do the sum with Voided bills excluded
            let fields = [
                ("total", "total", DSum),
                ("tip", "tip", DSum),
                ("tax_amount", "tax", DSum),
                ("discount_amount", "discount", DSum),
                ("service_fee_amount", "service_fee", DSum),
                ("service_fee_tax_amount", "service_fee_tax", DSum)
            ]
            var reduced = bills.sum(fields: fields) { !($0["voided"] as? Bool ?? false) }
            reduced["guests"] = doc["persons"] as? Int
            reduced["area_name"] = doc["area_name"] as? String
            reduced["driver_name"] = doc["driver_name"] as? String
            reduced["delivery"] = doc["delivery"] as? Bool
            emit([storeID, id[0...5], shift, area, (doc["driver"] as? String ?? BaseModel.idEmpty)], reduced)
        }, reduce: { (keys, values, rereduce) in
            guard let values = values as? [[String: Any]] else {
                return [:]
            }
            let fields = [
                ("total", DSum),
                ("tip", DSum),
                ("tax", DSum),
                ("discount", DSum),
                ("service_fee", DSum),
                ("service_fee_tax", DSum),
                ("guests", ISum)
            ]
            var reduced = values.sum(fields: fields)
            reduced["count"] = values.count
            
            let shifts = keys.map { key -> Int in
                guard let key = key as? [Any], let shift = key[2] as? Int else {
                    return 0
                }
                return shift
            }
            reduced["shifts"] = shifts.unique().sorted()
            
            if let first = values.first {
                reduced["area_name"] = first["area_name"] as? String
                reduced["driver_name"] = first["driver_name"] as? String
                reduced["delivery"] = first["delivery"] as? Bool
            }
            
            return reduced
        }, version: CouchbaseDatabase.VERSION )
        return view
    }
    
    func load(openingOrders storeID: String, forShift shiftID: String, inArea area: Area?, withFilter filter: String) -> [Order] {
       return loadProperties(openingOrders: storeID, forShift: shiftID, inArea: area, withFilter: filter)
            .map { properties in Order(JSON: properties)! }
    }
    
    func loadProperties(openingOrders storeID: String, forShift shiftID: String, inArea area: Area?, withFilter filter: String) -> [[String: Any]] {
        guard storeID.isNotEmpty, shiftID.isNotEmpty else {
            return []
        }
        let query = orderByOrderStatusView.createQuery()
        query.mapOnly = true
        query.prefetch = true
        query.startKey = [storeID, shiftID]
        query.endKey = [storeID, shiftID, [:]]
        
        if let area = area {
            if area.isDelivery {
                // Delivery area will consider the filter value
                query.postFilter = NSPredicate { (row, _) -> Bool in
                    guard let row = row as? CBLQueryRow,
                        let status = row.key2 as? String,
                        status != OrderStatus.voided.rawValue,
                        let properties = row.documentProperties,
                        let orderArea = properties["area"] as? String,
                        orderArea == area.id
                        else { return false }
                    if filter == "ALL" {
                        return true
                    } else {
                        let delivered = properties["delivered"] as? Bool ?? false
                        if filter == "DELIVERED" { return delivered }
                        else if filter == "PENDING" { return !delivered }
                    }
                    return false
                }
            } else {
                // Other areas just return the order in given area
                query.postFilter = NSPredicate { (row, _) -> Bool in
                    guard let row = row as? CBLQueryRow,
                        let status = row.key2 as? String,
                        status != OrderStatus.checked.rawValue,
                        status != OrderStatus.voided.rawValue,
                        let properties = row.documentProperties,
                        let orderArea = properties["area"] as? String,
                        orderArea == area.id
                        else { return false }
                    return true
                }
            }
        } else {
            // If no specific area is request, return all opening orders
            query.postFilter = NSPredicate { (row, _) -> Bool in
                guard let row = row as? CBLQueryRow,
                    let status = row.key2 as? String,
                    status != OrderStatus.checked.rawValue,
                    status != OrderStatus.voided.rawValue
                    else { return false }
                return true
            }
        }
        return query.loadPropertiesList()
    }
    
    func count(openingOrders storeID: String, forShift shiftID: String) -> UInt {
        guard storeID.isNotEmpty, shiftID.isNotEmpty else { return 0 }
        let query = orderByOrderStatusView.createQuery()
        query.keys = [
            [storeID, shiftID, OrderStatus.new.rawValue],
            [storeID, shiftID, OrderStatus.printed.rawValue],
            [storeID, shiftID, OrderStatus.submitted.rawValue]
        ]
        query.mapOnly = false
        return UInt(query.loadInt())
    }
    
    /// Return the post fitler predicate for filtering by statuses.
    ///
    /// - Parameter statuses: The `OrderStatus`es to filter for.
    /// - Returns: The `NSPredicate` to use as post filter.
    func postFilter(statuses: [OrderStatus]) -> NSPredicate {
        return NSPredicate { (row, _) -> Bool in
            // make sure there is a returned row
            guard let row = row as? CBLQueryRow else { return false }
            // ... with properties
            guard let properties = row.documentProperties else {
                return true // this is the post filter in case of reduce result
            }
            // ... and non-empty status
            guard let status = properties["status"] as? String, status.isNotEmpty else {
                return false
            }
            return statuses.isEmpty || statuses.contains { $0.rawValue == status }
        }
    }
    
    func load(orders storeID: String, forShift shiftID: String, matchingStatuses statuses: [OrderStatus], page: UInt, pageSize: UInt) -> QueryResult<Order> {
        return QueryResult<Order>(JSON: loadProperties(orders: storeID, forShift: shiftID, matchingStatuses: statuses, page: page, pageSize: pageSize))!
    }
    
    func loadProperties(orders storeID: String, forShift shiftID: String, matchingStatuses statuses: [OrderStatus], page: UInt, pageSize: UInt) -> [String: Any] {
        guard storeID.isNotEmpty, shiftID.isNotEmpty else {
            return [:]
        }
        // Summary
        let summaryQuery = orderByOrderStatusView.createQuery()
        if statuses.isEmpty {
            summaryQuery.startKey = [storeID, shiftID]
            summaryQuery.endKey = [storeID, shiftID, [:]]
        } else {
            summaryQuery.keys = statuses.map { [storeID, shiftID, $0.rawValue] }
        }
        let count = summaryQuery.loadInt()
        let summary: [String: Any] = ["count": count]
        // Total count is 0, no need to query for detail
        guard count > 0 else {
            return ["summary": summary]
        }
        // Rows detail / Ordered by order no
        let query = orderByOrderNoView.createQuery()
        query.startKey = [storeID, shiftID]
        query.endKey = [storeID, shiftID, [:]]
        query.postFilter = postFilter(statuses: statuses)
        query.mapOnly = true
        query.prefetch = true
        if pageSize > 0 { query.limit = pageSize }
        if page > 0 { query.skip = (page - 1) * pageSize }
        let rows = query.loadPropertiesList()
        let queryResult: [String: Any] = [
            "summary": summary,
            "rows": rows
        ]
        return queryResult
    }
}
