//
//  CouchbaseDatabase+Customer.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/1/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// MARK: - all_customer
extension CouchbaseDatabase {
    
    /// Group orders by store/name
    var allCustomersView: CBLView {
        // Get/Create view
        let view = database.viewNamed("all_customer")
        view.setMapBlock(Customer.allMapBlock!, reduce: totalReduce, version: CouchbaseDatabase.VERSION)
        return view
    }

    func load(customers storeID: String, page: UInt, pageSize: UInt) -> QueryResult<Customer> {
        guard storeID.isNotEmpty else {
            return QueryResult<Customer>()            
        }
        
        // Summary
        let summaryQuery = allCustomersView.createQuery()
        summaryQuery.keys = [storeID]
        let count = summaryQuery.loadInt()
        let summary = QuerySummary(count: count)
        
        // Total count is 0, no need to query for detail
        guard summary.rowCount > 0 else {
            return QueryResult<Customer>()
        }

        // Rows detail / Ordered by order no
        let query = allCustomersView.createQuery()
        query.keys = [storeID]
        query.mapOnly = true
        query.prefetch = true
        if pageSize > 0 { query.limit = pageSize }
        if page > 0 { query.skip = (page - 1) * pageSize }
        let rows: [Customer] = query.loadModels()
        return QueryResult(rows: rows, summary: summary)
    }

    func load(customers storeID: String, query: (String, String, String, String), limit: UInt) -> [Customer] {
        return loadProperties(customers: storeID, query: query, limit: limit)
            .map { properties in Customer(JSON: properties)! }
    }
    
    func loadProperties(customers storeID: String, query: (String, String, String, String), limit: UInt) -> [[String: Any]] {
        guard storeID.isNotEmpty, limit > 0 else {
            return []
        }
        var (name, phone, email, address) = query
        guard name.isNotEmpty || phone.isNotEmpty || email.isNotEmpty || address.isNotEmpty else {
            return []
        }
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
        return query.loadPropertiesList()
    }
}
