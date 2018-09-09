//
//  CouchbaseDatabase+Transaction.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Report row for Transaction Detail Report.
class TransactionReportRow: Mappable, Equatable {
    var order: Order? = nil
    var bill: Bill? = nil
    var transaction: Transaction? = nil
    var customer: String? = nil
    var hasCustomer: Bool { return customer?.isNotEmpty ?? false }
    
    init() { }
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        order <- map["order"]
        bill <- map["order"]
        transaction <- map["order"]
        customer <- map["order"]
    }
    
    public static func ==(lhs: TransactionReportRow, rhs: TransactionReportRow) -> Bool {
        return false
    }
}

extension CouchbaseDatabase {
    
    /// Group orders by store/shift/status
    var transactionByTypeView: CBLView {
        // Get/Create view
        let view = database.viewNamed("transaction_by_type")
        view.setMapBlock({ (doc, emit) in
            // Make sure good inputs
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == Transaction.documentType,
                let id = doc["id"] as? String, id.count > 6 ,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                let statusValue = doc["status"] as? String, statusValue.isNotEmpty,
                let status = TransactionStatus(rawValue: statusValue),
                let shift = doc["shift_index"] as? Int, shift > 0,
                let transTypeValue = doc["trans_type"] as? String, transTypeValue.isNotEmpty,
                let transType = TransactionType(rawValue: transTypeValue), transType != TransactionType.batchclose,
                let transNum = doc["trans_num"] as? Int64, transNum > 0
                else { return }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            var approvedAmount = doc["approved_amount"] as? Double ?? 0
            var tipAmount = doc["tip_amount"] as? Double ?? 0
            if status.isVoided {
                approvedAmount = 0
                tipAmount = 0
            } else if transType == .creditRefund {
                approvedAmount = -approvedAmount
                tipAmount = -tipAmount
            }
            // Custom payment Type need a special trans_type which include
            // 1. custom as prefix
            // 2. id of custom payment type
            // 3. name of custom payment type
            // all combined by $ sign
            var emitTransType = "\(transType.rawValue)"
            if transType == .custom {
                let customTransType = (doc["custom_trans_type"] as? String) ?? ""
                let customTransTypeName = (doc["custom_trans_type_name"] as? String) ?? ""
                emitTransType += "$\(customTransType)$\(customTransTypeName)";
            }
            // Sub Payment Type need to be appended also
            if let subPaymentType = doc["sub_payment_type"] as? String, subPaymentType.isNotEmpty {
                let subPaymentTypeName = (doc["sub_payment_type_name"] as? String) ?? ""
                emitTransType += "$\(subPaymentType)$\(subPaymentTypeName)"
            }
            
            let cardType = (doc["card_type"] as? String) ?? ""
            emit([storeID, id[0...5], shift, emitTransType, cardType],
                 ["total": approvedAmount, "tip": tipAmount])
        }, reduce: { (keys, values, rereduce) in
            guard let values = values as? [[String:Any]] else {
                return [:]
            }
            var reduced = values.sum(fields: [("total", DSum), ("tip", DSum)])
            reduced["count"] = values.count
            
            let shifts = keys.map { key -> Int in
                guard let key = key as? [Any], let shift = key[2] as? Int else {
                    return 0
                }
                return shift
            }
            reduced["shifts"] = shifts.unique().sorted()
            
            return reduced
        }, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    /// Generate the Shift/Area related transactions view Map block.
    ///
    /// - Returns: The `CBLMapBlock`.
    private func transactionShiftAreaMap(with keys: @escaping (String, String, Int, String, Int64) -> [Any] = { [$0, $1, $2, $3, $4] }) -> CBLMapBlock {
        return { (doc, emit) in
            // Make sure good inputs
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == Transaction.documentType,
                let id = doc["id"] as? String, id.count > 6 ,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                let statusValue = doc["status"] as? String, statusValue.isNotEmpty,
                let status = TransactionStatus(rawValue: statusValue),
                let shift = doc["shift_index"] as? Int, shift > 0,
                let transTypeValue = doc["trans_type"] as? String, transTypeValue.isNotEmpty,
                let transType = TransactionType(rawValue: transTypeValue), transType != TransactionType.batchclose,
                let transNum = doc["trans_num"] as? Int64, transNum > 0
                else { return }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            var approvedAmount = doc["approved_amount"] as? Double ?? 0
            var tipAmount = doc["tip_amount"] as? Double ?? 0
            if status.isVoided {
                approvedAmount = 0
                tipAmount = 0
            } else if transType == .creditRefund {
                approvedAmount = -approvedAmount
                tipAmount = -tipAmount
            }
            let area = (doc["area"] as? String) ?? ""
            emit(keys(storeID, id[0...5], shift, area, transNum),
                 ["total": approvedAmount, "tip": tipAmount])
        }
    }
    
    /// For reporting on the payment type of orders.
    var transactionByShiftAreaView: CBLView {
        // Get/Create view
        let view = database.viewNamed("transaction_by_shift_area")
        view.setMapBlock(
            transactionShiftAreaMap(),
            reduce: { (keys, values, rereduce) in
                guard let values = values as? [[String:Any]] else {
                    return [:]
                }
                var reduced = values.sum(fields: [("total", DSum), ("tip", DSum)])
                reduced["count"] = values.count
                // Summary shifts
                let shifts = keys.map { key -> Int in
                    guard let key = key as? [Any], let shift = key[2] as? Int else {
                        return 0
                    }
                    return shift
                }
                reduced["shifts"] = shifts.unique().sorted()
                // Summary areas
                let areas = keys.map { key -> String in
                    guard let key = key as? [Any], let area = key[3] as? String else {
                        return ""
                    }
                    return area
                }
                reduced["areas"] = areas.unique()
                
                return reduced
        }, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    /// For reporting on the payment type of orders.
    var transactionByAreaShiftView: CBLView {
        // Get/Create view
        let view = database.viewNamed("transaction_by_area_shift")
        view.setMapBlock(
            transactionShiftAreaMap { [$0, $1, $3, $2, $4] },
            reduce: { (keys, values, rereduce) in
                guard let values = values as? [[String:Any]] else {
                    return [:]
                }
                var reduced = values.sum(fields: [("total", DSum), ("tip", DSum)])
                reduced["count"] = values.count
                // Summary shifts
                let shifts = keys.map { key -> Int in
                    guard let key = key as? [Any], let shift = key[3] as? Int else {
                        return 0
                    }
                    return shift
                }
                reduced["shifts"] = shifts.unique().sorted()
                // Summary areas
                let areas = keys.map { key -> String in
                    guard let key = key as? [Any], let area = key[2] as? String else {
                        return ""
                    }
                    return area
                }
                reduced["areas"] = areas.unique()
                
                return reduced
        }, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    func load(transactions storeID: String, fromDate: Date, toDate: Date, shift: Int, area areaID: String, page: UInt, pageSize: UInt) -> ReportQueryResult<TransactionReportRow> {
        guard storeID.isNotEmpty else {
            return ReportQueryResult()
        }
        var query: CBLQuery!
        // Setup query parameters for storeId, date and shift
        let fdate = fromDate.toString("yyMMdd")
        //        let tdate = toDate.toString("yyMMdd")
        if areaID.isEmpty {
            query = transactionByShiftAreaView.createQuery()
            if shift > 0 {
                query.startKey = [storeID, fdate, shift]
                query.endKey = [storeID, fdate, shift, [:], [:]]
            } else {
                query.startKey = [storeID, fdate]
                query.endKey = [storeID, fdate, [:], [:], [:]]
            }
        } else {
            query = transactionByAreaShiftView.createQuery()
            if shift > 0 {
                query.startKey = [storeID, fdate, areaID, shift]
                query.endKey = [storeID, fdate, areaID, shift, [:]]
            } else {
                query.startKey = [storeID, fdate, areaID]
                query.endKey = [storeID, fdate, areaID, [:], [:]]
            }
        }
        // Query the Summary
        guard let summary = query.loadDict() else {
            return ReportQueryResult()
        }
        // Run the detail query
        query.mapOnly = true
        query.prefetch = true
        if pageSize > 0 { query.limit = pageSize }
        if page > 0 { query.skip = (page - 1) * pageSize }
        // Load all transaction first
        let transactions: [Transaction] = query.loadModels()
        // The fill in the Order/Bill info
        let orders: [Order?] = load(multi: transactions.map { $0.order}.unique())
        let rows = transactions.map { t -> TransactionReportRow in
            let row = TransactionReportRow()
            row.transaction = t
            row.order = orders.first { order in
                order == nil ? false : t.order == order!.id                
                } ?? Order() // TODO: Revisit this default thingy
            row.bill = row.order?.bills.first { bill in t.bill == bill.id }
            row.customer = row.order?.customerSummary
            return row
        }
        return ReportQueryResult(rows: rows, summary: ReportQuerySummary(JSON: summary)!)
    }
    
    func load(transactions storeID: String, fromDate: Date, toDate: Date, area areaID: String, groupedBy shift: Int) -> [GroupedByShiftQueryResult<Transaction>] {
        var query: CBLQuery!
        // Setup query parameters for storeId, date and shift
        let fdate = fromDate.toString("yyMMdd")
        //        let tdate = toDate.toString("yyMMdd")
        if areaID.isEmpty {
            query = transactionByShiftAreaView.createQuery()
            if shift > 0 {
                query.startKey = [storeID, fdate, shift]
                query.endKey = [storeID, fdate, shift, [:], [:]]
            } else {
                query.startKey = [storeID, fdate]
                query.endKey = [storeID, fdate, [:], [:], [:]]
            }
        } else {
            query = transactionByAreaShiftView.createQuery()
            if shift > 0 {
                query.startKey = [storeID, fdate, areaID, shift]
                query.endKey = [storeID, fdate, areaID, shift, [:]]
            } else {
                query.startKey = [storeID, fdate, areaID]
                query.endKey = [storeID, fdate, areaID, [:], [:]]
            }
        }
        // Query the detail first
        query.mapOnly = true
        query.prefetch = true
        let rows: [Transaction] = query.loadModels()
        // ... then the summary for each shift
        query.groupLevel = areaID.isEmpty ? 3 : 4
        return query.loadMulti()
            .map { (key, value) in
                let kshift = key[2] as! Int
                let shiftRows = rows.filter { Int($0.shiftIndex) == kshift }
                let summary = QuerySummary(JSON: value)!
                return GroupedByShiftQueryResult(shift: kshift, rows: shiftRows, summary: summary)
            }.sorted { (lhs, rhs) in
                lhs.shift > rhs.shift                
        }
    }
}

