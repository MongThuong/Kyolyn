//
//  Database+Queries.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/11/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - Common queries stuff.
extension Database {
    
    /// Simple reduce to return the total count of rows.
    var totalReduce: CBLReduceBlock {
        return { (keys, values, rereduce) in values.count }
    }
}

// MARK: - station_by_mac
extension Database {
    
    var stationByMacView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
        let view = database.viewNamed("station_by_mac")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Station.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let macAddress = doc["mac_address"] as? String, macAddress.isNotEmpty else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, macAddress.lowercased()], nil)
        }, version: Database.VERSION)
        return view
    }
    
    /// Load a single station base on its MAC address.
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - mac: The station's MAC address to load for.
    /// - Returns: The `Station` or `nil` if not found.
    func load(_ storeID: String, mac: String) -> Station? {
        guard storeID.isNotEmpty, mac.isNotEmpty else {
            return nil
        }
        let query = stationByMacView.createQuery()
        query.keys = [ [storeID, mac.lowercased()] ]
        query.mapOnly = true
        query.prefetch = true
        do {
            let result = try query.run()
            if let document = result.nextRow()?.document {
                return Station(for: document)
            }
        } catch {
            e("Could not load Station \(storeID)/\(mac): \(error)")
        }
        return nil
    }
}

// MARK: - employee_by_passkey
extension Database {
    
    var employeeByPasskeyView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
        // Get/Create view
        let view = database.viewNamed("employee_by_passkey")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Employee.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let passkey = doc["passkey"] as? String, passkey.isNotEmpty else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, passkey], nil)
        }, version: Database.VERSION)
        return view
    }

    /// Load a single employee by passkey.
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - passkey: The employee's passkey.
    /// - Returns: The `Employee` or `nil` if not found.
    func load(_ storeID: String, passkey: String) -> Employee? {
        guard storeID.isNotEmpty, passkey.isNotEmpty else {
            return nil
        }
        let query = employeeByPasskeyView.createQuery()
        query.keys = [ [storeID, passkey] ]
        query.mapOnly = true
        query.prefetch = true
        do {
            let result = try query.run()
            if let document = result.nextRow()?.document {
                return Employee(for: document)
            }
        } catch {
            e("Could not load Employee \(storeID)/\(passkey): \(error)")
        }
        return nil
    }
    
    /// Load all drivers.
    ///
    /// - Parameter storeID: the `Store` to load from.
    /// - Returns: the list of `Driver`s of the given `Store`.
    func load(drivers storeID: String) -> [Employee] {
        guard storeID.isNotEmpty else {
            return []
        }
        let query = employeeByPasskeyView.createQuery()
        query.startKey = [storeID]
        query.endKey = [storeID, [:]]
        query.mapOnly = true
        query.prefetch = true
        query.postFilter = NSPredicate { (row, _) -> Bool in
            guard let row = row as? CBLQueryRow,
                let properties = row.documentProperties,
                let isDriver = properties["delivery_driver"] as? Bool
                else { return false }
            return isDriver
        }
        return query.loadModels()
    }
    
    /// Load the default driver for delivery area.
    ///
    /// - Parameter storeID: the `Store` to load from.
    /// - Returns: the default of `Driver` of the given `Store`.
    func loadDefaultDriver(storeID: String) -> Employee? {
        guard storeID.isNotEmpty else {
            return nil
        }
        let query = employeeByPasskeyView.createQuery()
        query.startKey = [storeID]
        query.endKey = [storeID, [:]]
        query.mapOnly = true
        query.prefetch = true
        query.postFilter = NSPredicate { (row, _) -> Bool in
            guard let row = row as? CBLQueryRow,
                let properties = row.documentProperties,
                let isDriver = properties["delivery_driver"] as? Bool
                else { return false }
            return isDriver
        }
        query.limit = 1
        do {
            let result = try query.run()
            if let document = result.nextRow()?.document {
                return Employee(for: document)
            }
        } catch {
            e("Could not load default driver for \(storeID): \(error)")
        }
        return nil
    }
    
}

// MARK: - Menu (Categories/Items/Modifiers)
extension Database {
    
    /// `CouchbaseLite.CBLMapBlock` for view `item_by_category`
    /// Return ALL `Item`s that
    /// 1. Has id
    /// 2. Has merchant id
    /// 3. Not yet deleted
    /// 4. Has a name
    private func mapItemByCategory(doc: [String : Any], emit: CBLMapEmitBlock) {
        // Make sure good inputs
        guard doc["deleted"] == nil,
            let type = doc["type"] as? String, type == Item.documentType,
            let id = doc["id"] as? String, id.isNotEmpty,
            let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
            // having a category
            let catID = doc["category"] as? String, catID.isNotEmpty,
            // not hidden
            (doc["hidden"] as? Bool ?? false) == false,
            // having a good name
            let name = doc["name"] as? String, name.isNotEmpty else {
                return
        }
        // User storeid (new Store) or merchantid (old Store)
        let storeID = (doc["storeid"] as? String) ?? merchantID
        emit([storeID, catID], nil)
    }
    
    /// Load all items (excluding the hidden ones) for a given store that belongs to given category.
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - category: The `Category` to load for.
    /// - Returns: All `Item`s belong to the given `Category`.
    func loadItems(_ storeID: String, category: String) -> [Item] {
        guard let database = database, storeID.isNotEmpty, !category.isEmpty else { return [] }
        
        // Get/Create view
        let view = database.viewNamed("item_by_category")
        view.setMapBlock(mapItemByCategory, version: Database.VERSION)
        let query = view.createQuery()
        query.keys = [ [storeID, category] ]
        query.mapOnly = true
        query.prefetch = true
        return query.loadModels()
    }
    
    /// Load all modifiers (excluding the hidden ones) for a given store that belongs to given item.
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - item: The `Item` to load for.
    /// - Returns: All `Modifier`s belong to the given `Category`.
    func loadModifiers(forItem itemID: String) -> [Modifier] {
        // Load the item
        guard let _ = database,
            let item: Item = load(itemID) else {
                return []
        }
        return item.modifiers
            .map { ref -> Modifier? in
                guard let modifier: Modifier = self.load(ref.id) else { return nil }
                modifier.required = ref.required
                modifier.sameline = ref.sameline
                return modifier
            }
            .filter { $0 != nil }
            .map { $0! }
            .sorted(by: { (lhs, rhs) -> Bool in
                return "\(lhs.required ? 0 : 1)\(lhs.name)" < "\(rhs.required ? 0 : 1)\(rhs.name)"
        })
    }
}

/// MARK: - Shift
extension Database {
    /// Return the currently opening shift.
    ///
    /// - Parameter storeID: The store to open for.
    /// - Returns: current active `Shift` or nil of none is being opened.
    func loadActiveShift(_ storeID: String) -> Shift? {
        guard let database = database, storeID.isNotEmpty else {
            return nil
        }
        // Get/Create view
        let view = database.viewNamed("opening_shift")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Shift.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    // not yet closed
                    (doc["closed_at"] as? String) == nil ||
                        (doc["closed_at"] as! String).isEmpty else {
                            return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit(storeID, nil)
        }, version: Database.VERSION)
        // Create query
        let query = view.createQuery()
        // Apply keys
        query.keys = [ storeID ]
        // No reducing is needed
        query.mapOnly = true
        // But document is needed
        query.prefetch = true
        // Run query and return the first item
        do {
            // Run query
            let result = try query.run()
            if result.count == 0 { return nil }
            return Shift(for: result.row(at: 0).document!)
        } catch {
            e("Could not load from \(view.name): \(error)")
        }
        // Not found
        return nil
    }
    
    
    /// Return the total shift in a single day.
    ///
    /// - Parameters:
    ///   - storeID: The store to count for.
    ///   - day: The day to count for.
    /// - Returns: The shift count in given day.
    func countShifts(_ storeID: String, in day: Date) -> UInt {
        guard let database = database, storeID.isNotEmpty else {
            return 0
        }
        // Get/Create view
        let view = database.viewNamed("shift_by_date")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Shift.documentType,
                    let id = doc["id"] as? String, id.count > 6 ,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty
                    else { return }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, id[0...5]], nil)
        }, reduce: totalReduce, version: Database.VERSION)
        // Create query
        let query = view.createQuery()
        // Apply keys
        query.keys = [ [ storeID, day.toString("YYMMdd") ] ]
        // No reducing is needed
        query.mapOnly = false
        // But document is needed
        query.prefetch = false
        // Run query and return the first item
        do {
            // Run query
            let result = try query.run()
            guard result.count > 0, let count = result.row(at: 0).value as? Int else {
                return 0
            }
            return UInt(count)
        } catch {
            e("Could not load from \(view.name): \(error)")
        }
        // Not found
        return 0
    }
}

// MARK: - order_by_status + order_by_order_no
extension Database {
    
    /// Group orders by store/shift/status
    var orderByOrderNoView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
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
        }, reduce: totalReduce, version: Database.VERSION)
        return view
    }
    
    /// Group orders by store/shift/status
    var orderByOrderStatusView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
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
        }, reduce: totalReduce, version: Database.VERSION)
        return view
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
            guard let status = properties["status"] as? String, status.isNotEmpty else { return false }
            return statuses.contains { $0.rawValue == status }
        }
    }
    
    /// Load orders by given statuses
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    ///   - statuses: List of `OrderStatus`es to load for.
    ///   - page: The page to load for.
    ///   - pageSize: The page size to load for.
    /// - Returns: `Order`s that matches the loading conditions with its summary.
    func load(orders storeID: String, shift shiftID: String, for statuses: [OrderStatus], page: UInt = 0, pageSize: UInt = 0) -> QueryResult<Order> {
        guard storeID.isNotEmpty, shiftID.isNotEmpty, statuses.isNotEmpty else {
            return QueryResult<Order>()
        }
            // Summary
        let summaryQuery = orderByOrderStatusView.createQuery()
        summaryQuery.keys = statuses.map { [storeID, shiftID, $0.rawValue] }
        let count = summaryQuery.loadInt()
        let summary = QuerySummary.with(count: count)
        
        // Total count is 0, no need to query for detail
        guard summary.rowCount > 0 else {
            return QueryResult<Order>()
        }
        
        // Rows detail / Ordered by order no
        let query = orderByOrderNoView.createQuery()
        query.startKey = [storeID, shiftID]
        query.endKey = [storeID, shiftID, [:]]
        query.postFilter = self.postFilter(statuses: statuses)
        query.mapOnly = true
        query.prefetch = true
        if pageSize > 0 { query.limit = pageSize }
        if page > 0 { query.skip = (page - 1) * pageSize }
        let rows: [Order] = query.loadModels()
        return QueryResult(rows: rows, summary: summary)
    }
    
    /// Load Orders in submitted status (opening).
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    /// - Returns: `Order`s that matches the loading conditions.
    func load(openingOrders storeID: String, shift shiftID: String, area: Area? = nil, filter: String = "PENDING") -> [Order] {
        guard storeID.isNotEmpty, shiftID.isNotEmpty else { return [] }
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
        return query.loadModels()
    }
    
    /// Return the number of sumbitted orders (opening) for a given store.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    /// - Returns: Number of opening `Order`s.
    func count(openingOrders storeID: String, shift shiftID: String) -> UInt {
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
}

/// MARK: - unsettled_transactions
extension Database {
    
    /// Group transactions by store/shift/transNo
    var unsettledTransactionsView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
        // Get/Create view
        let view = database.viewNamed("unsettled_transactions")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Transaction.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let shiftID = doc["shift"] as? String, shiftID.isNotEmpty,
                    let status = doc["status"] as? String, status.isNotEmpty,
                    status != TransactionStatus.settled.rawValue,
                    status != TransactionStatus.voidedSettled.rawValue,
                    let transType = doc["trans_type"] as? String, transType.isNotEmpty,
                    transType != TransactionType.batchclose.rawValue,
                    let transNum = doc["trans_num"] as? Int, transNum > 0
                    else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, shiftID, transNum], nil)
        }, reduce: totalReduce, version: Database.VERSION)
        return view
    }
    
    /// Group VOIDED transactions by store/shift/transNo
    var unsettledVoidedTransactionsView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
        // Get/Create view
        let view = database.viewNamed("unsettled_voided_transactions")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Transaction.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let shiftID = doc["shift"] as? String, shiftID.isNotEmpty,
                    let status = doc["status"] as? String, status.isNotEmpty,
                    status == TransactionStatus.voided.rawValue,
                    let transType = doc["trans_type"] as? String, transType.isNotEmpty,
                    transType != TransactionType.batchclose.rawValue,
                    let transNum = doc["trans_num"] as? Int, transNum > 0
                    else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, shiftID, transNum], nil)
        }, reduce: totalReduce, version: Database.VERSION)
        return view
    }

    /// Group transactions by store/shift/transType/transNo
    var unsettledTransactionsByTypeView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
        // Get/Create view
        let view = database.viewNamed("unsettled_transactions_by_type")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Transaction.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let shiftID = doc["shift"] as? String, shiftID.isNotEmpty,
                    let status = doc["status"] as? String, status.isNotEmpty,
                    status != TransactionStatus.settled.rawValue,
                    status != TransactionStatus.voidedSettled.rawValue,
                    var transType = doc["trans_type"] as? String, transType.isNotEmpty,
                    transType != TransactionType.batchclose.rawValue,
                    let transNum = doc["trans_num"] as? Int, transNum > 0
                    else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID

                // Append the custom trans type key
                if transType == TransactionType.custom.rawValue,
                    let customTransType = doc["custom_trans_type"] as? String,
                    customTransType.isNotEmpty {
                    transType += "$\(customTransType)"
                }
                // Append the sub payment type key
                if let subPaymentType = doc["sub_payment_type"] as? String,
                    subPaymentType.isNotEmpty {
                    transType += "$\(subPaymentType)"
                }

                emit([storeID, shiftID, transType, transNum], nil)
        }, reduce: totalReduce, version: Database.VERSION )
        return view
    }
    
    /// Load unsettled transactions.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    ///   - paymentType: The `PaymentType` tot load for
    ///   - limit: Number of record to return.
    ///   - skip: Number of record to skip.
    /// - Returns: `Transaction`s that matches the loading conditions with its summary.
    func load(unsettledTransactions storeID: String, shift shiftID: String, for paymentType: String = "", limit: UInt = 0, skip: UInt = 0) -> QueryResult<Transaction> {
        guard storeID.isNotEmpty, shiftID.isNotEmpty else {
            return QueryResult<Transaction>()
        }
        
        var query: CBLQuery!
        if paymentType.isEmpty {
            query = unsettledTransactionsView.createQuery()
            query.startKey = [storeID, shiftID]
            query.endKey = [storeID, shiftID, [:]]
        } else if paymentType == TransactionType.creditVoid.rawValue {
            query = unsettledVoidedTransactionsView.createQuery()
            query.startKey = [storeID, shiftID]
            query.endKey = [storeID, shiftID, [:]]
        } else {
            query = unsettledTransactionsByTypeView.createQuery()
            query.startKey = [storeID, shiftID, paymentType]
            query.endKey = [storeID, shiftID, paymentType, [:]]
        }

        // Run query and return the first item
        let count = query.loadInt()
        let summary = QuerySummary.with(count: count)
        // Total count is 0, no need to query for detail
        guard summary.rowCount > 0 else {
            return QueryResult<Transaction>()
        }
        
        // Rows detail / Ordered by order no
        query.mapOnly = true
        query.prefetch = true
        if limit > 0 { query.limit = limit }
        if skip > 0 { query.skip = skip }
        let rows: [Transaction] = query.loadModels()
        return QueryResult(rows: rows, summary: summary)
    }
    
    /// Load ALL unsettled transactions.
    ///
    /// - Parameter storeID: the `Store` to load for.
    func load(unsettledTransactions storeID: String) -> [Transaction] {
        guard storeID.isNotEmpty else { return [] }
        let query = unsettledTransactionsView.createQuery()
        query.startKey = [storeID]
        query.endKey = [storeID, [:]]
        query.prefetch = true
        query.mapOnly = true
        return query.loadModels()
    }

    /// Count the unsettled transactions.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    /// - Returns: Number of unsettled transactions.
    func count(unsettledTransactions storeID: String, shift shiftID: String) -> UInt {
        guard storeID.isNotEmpty, shiftID.isNotEmpty else {
            return 0
        }
        let query = unsettledTransactionsView.createQuery()
        query.startKey = [storeID, shiftID]
        query.endKey = [storeID, shiftID, [:]]
        do {
            return UInt((try query.run().nextRow()?.value as? Int) ?? 0)
        } catch {
            e("Could not load from \(query.view?.name ?? ""): \(error)")
            return 0
        }
    }
}

/// MARK: - all_customer
extension Database {
    
    /// Group orders by store/name
    var allCustomersView: CBLView {
        guard let database = self.database else { fatalError("database not init") }
        // Get/Create view
        let view = database.viewNamed("all_customer")
        view.setMapBlock(Customer.allMapBlock!, reduce: totalReduce, version: Database.VERSION)
        return view
    }
    
    /// Load customer with pagination support.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - limit: Number of record to return.
    ///   - skip: Number of record to skip.
    /// - Returns: `Customers`s that matches the loading conditions.
    func loadCustomers(_ storeID: String, limit: UInt = 0, skip: UInt = 0) -> QueryResult<Customer> {
        guard storeID.isNotEmpty else { return QueryResult<Customer>() }
        // Rows detail / Ordered by order no
        let query = allCustomersView.createQuery()
        query.mapOnly = true
        query.prefetch = true
        if limit > 0 { query.limit = limit }
        if skip > 0 { query.skip = skip }
        let rows: [Customer] = query.loadModels()
        return QueryResult(rows: rows)
    }

    
    /// Find customers based on combination of Name, Phone, Email, Address.
    ///
    /// - Parameters:
    ///   - storeID: The Store to search in.
    ///   - query: The customer info to search for.
    ///   - limit: The limit of returned result.
    /// - Returns: The list of matched customers.
    func findCustomers(_ storeID: String, query: (String, String, String, String), limit: UInt = 10) -> [Customer] {
        
        guard storeID.isNotEmpty, limit > 0 else { return [] }
        var (name, phone, email, address) = query
        guard name.isNotEmpty || phone.isNotEmpty || email.isNotEmpty || address.isNotEmpty else { return [] }
        let query = allCustomersView.createQuery()
        query.prefetch = true
        query.mapOnly = true
        query.keys = [storeID]
        query.limit = limit
        // It is too complicate thus we use post filter instead
        name = name.lowercased()
        phone = phone.lowercased()
        email = email.lowercased()
        address = address.lowercased()
        query.postFilter = NSPredicate(block: { (r, _) -> Bool in
            guard let row = r as? CBLQueryRow, let properties = row.documentProperties else { return false }
            
            if name.isNotEmpty {
                guard let v = properties["name"] as? String, v.lowercased().hasPrefix(name) else { return false }
            }
            if phone.isNotEmpty {
                guard let v = properties["mobilephone"] as? String, v.lowercased().hasPrefix(phone) else { return false }
            }
            if email.isNotEmpty {
                guard let v = properties["email"] as? String, v.lowercased().hasPrefix(email) else { return false }
            }
            if address.isNotEmpty {
                guard let v = properties["address"] as? String, v.lowercased().hasPrefix(address) else { return false }
            }
            return true
        })
        return query.loadModels()
    }
}

