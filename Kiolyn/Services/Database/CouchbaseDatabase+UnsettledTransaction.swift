//
//  CouchbaseDatabase+UnsettledTransaction.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension CouchbaseDatabase {
    /// Group transactions by store/shift/transNo
    var unsettledTransactionsView: CBLView {
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
        }, reduce: totalReduce, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    /// Group VOIDED transactions by store/shift/transNo
    var unsettledVoidedTransactionsView: CBLView {
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
        }, reduce: totalReduce, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    /// Group transactions by store/shift/transType/transNo
    var unsettledTransactionsByTypeView: CBLView {
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
        }, reduce: totalReduce, version: CouchbaseDatabase.VERSION )
        return view
    }
    
    func load(unsettledTransactions storeID: String, shift shiftID: String, for paymentType: String, page: UInt, pageSize: UInt) -> QueryResult<Transaction> {
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
        let summary = QuerySummary(count: count)
        // Total count is 0, no need to query for detail
        guard summary.rowCount > 0 else {
            return QueryResult<Transaction>()
        }
        
        // Rows detail / Ordered by order no
        query.mapOnly = true
        query.prefetch = true
        if pageSize > 0 { query.limit = pageSize }
        if page > 0 { query.skip = (page - 1) * pageSize }
        let rows: [Transaction] = query.loadModels()
        return QueryResult(rows: rows, summary: summary)
    }
    
    func load(unsettledTransactions storeID: String) -> [Transaction] {
        guard storeID.isNotEmpty else { return [] }
        let query = unsettledTransactionsView.createQuery()
        query.startKey = [storeID]
        query.endKey = [storeID, [:]]
        query.prefetch = true
        query.mapOnly = true
        return query.loadModels()
    }
    
    func count(unsettledTransactions storeID: String, forShift shiftID: String) -> UInt {
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
