//
//  CouchbaseDatabase+ByEmployeeReport.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// For report relating to payment type.
class EmployeeTotalReportRow: TotalReportRow {
    var opening: Int = 0
    var closing: Int = 0
    
    /// For displaying order detail
    var order: Order?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        opening <- map["opening"]
        closing <- map["closing"]
    }
}

extension CouchbaseDatabase {
    /// Generate the Shift/Server related orders view Map block.
    ///
    /// - Returns: The `CBLMapBlock`.
    private func orderShiftServerMap(with keys: @escaping (String, String, Int, String) -> [Any] = { [$0, $1, $2, $3] }) -> CBLMapBlock {
        return { (doc, emit) in
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == Order.documentType,
                let id = doc["id"] as? String, id.count > 6 ,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                let statusValue = doc["status"] as? String, statusValue.isNotEmpty,
                let status = OrderStatus(rawValue: statusValue), status == .checked,
                let shift = doc["shift"] as? Int, shift > 0,
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
            let createdBy = doc["created_by"] as? String ?? ""
            let closedBy = doc["closed_by"] as? String ?? ""
            reduced["guests"] = doc["persons"] as? Int
            reduced["name"] = doc["created_by_name"] as? String
            reduced["opening"] = 1
            reduced["closing"] = createdBy == closedBy ? 1 : 0
            emit(keys(storeID, id[0...5], shift, createdBy), reduced)
        }
    }
    
    /// Group orders by store/shift/status
    var orderByShiftServerView: CBLView {
        // Get/Create view
        let view = database.viewNamed("order_by_shift_server")
        view.setMapBlock(
            orderShiftServerMap(),
            reduce: { (keys, values, rereduce) in
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
                    ("guests", ISum),
                    ("opening", ISum),
                    ("closing", ISum)
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
                
                let servers = keys.map { key -> String in
                    guard let key = key as? [Any], let server = key[3] as? String else {
                        return ""
                    }
                    return server
                }
                reduced["servers"] = servers.unique()
                
                if let first = values.first {
                    reduced["name"] = (first["name"] as? String) ?? ""
                }
                
                return reduced
        }, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    /// Group orders by store/shift/status
    var orderByServerShiftView: CBLView {
        // Get/Create view
        let view = database.viewNamed("order_by_server_shift")
        view.setMapBlock(
            orderShiftServerMap { [$0, $1, $3, $2] },
            reduce: { (keys, values, rereduce) in
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
                return reduced
        }, version: CouchbaseDatabase.VERSION )
        return view
    }
    
    func load(byEmployeeReport storeID: String, fromDate: Date, toDate: Date, shift: Int) -> ReportQueryResult<EmployeeTotalReportRow> {
        guard storeID.isNotEmpty else {
            return ReportQueryResult()
        }
        
        let query = orderByShiftServerView.createQuery()
        
        let fdate = fromDate.toString("yyMMdd")
        //        let tdate = toDate.toString("yyMMdd")
        if shift > 0 {
            query.startKey = [storeID, fdate, shift]
            query.endKey = [storeID, fdate, shift, [:]]
        } else {
            query.startKey = [storeID, fdate]
            query.endKey = [storeID, fdate, [:], [:]]
        }
        // Query the Summary
        query.groupLevel = 0
        guard let summaryDict = query.loadDict() else {
            return ReportQueryResult()
        }
        // Run the grouped query
        query.groupLevel = 4
        let rows = query.loadMulti().map { (key, value) -> EmployeeTotalReportRow in
            var nvalue = value
            nvalue["shift"] = key[2] as! Int
            return EmployeeTotalReportRow(JSON: nvalue)!
        }
        var summary = summaryDict
        summary["row_count"] = rows.count
        return ReportQueryResult<EmployeeTotalReportRow>(rows: rows, summary: ReportQuerySummary(JSON: summary)!)
    }
    
    func load(byEmployeeReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<EmployeeTotalReportRow>] {
        guard storeID.isNotEmpty else { return [] }
        
        let query = orderByShiftServerView.createQuery()
        
        let fdate = fromDate.toString("yyMMdd")
        //        let tdate = toDate.toString("yyMMdd")
        if shift > 0 {
            query.startKey = [storeID, fdate, shift]
            query.endKey = [storeID, fdate, shift, [:]]
        } else {
            query.startKey = [storeID, fdate]
            query.endKey = [storeID, fdate, [:], [:]]
        }
        // Query the detail first
        query.groupLevel = 4
        let rows = query.loadMulti().map { (key, value) -> EmployeeTotalReportRow in
            var nvalue = value
            nvalue["shift"] = key[2] as! Int
            nvalue["created_by"] = key[3] as! String
            return EmployeeTotalReportRow(JSON: nvalue)!
        }
        // ... then the summary for each shift
        query.groupLevel = 3
        return query.loadMulti()
            .map { (key, value) -> GroupedByShiftQueryResult<EmployeeTotalReportRow> in
                let kshift = key[2] as! Int
                let shiftRows = rows.filter { $0.shift == kshift }
                let summary = QuerySummary(JSON: value)!
                return GroupedByShiftQueryResult(shift: kshift, rows: shiftRows, summary: summary)
            }
            .sorted { (lhs, rhs) in lhs.shift > rhs.shift }
    }
    
    func load(orders storeID: String, ofEmployee emp: String, fromDate: Date, toDate: Date, shift: Int, page: UInt, pageSize: UInt) -> QueryResult<Order> {
        guard storeID.isNotEmpty, emp.isNotEmpty else {
            return QueryResult()
        }
        
        let query = orderByServerShiftView.createQuery()
        let fdate = fromDate.toString("yyMMdd")
        //        let tdate = toDate.toString("yyMMdd")
        if shift > 0 {
            query.keys = [[storeID, fdate, emp, shift]]
        } else {
            query.startKey = [storeID, fdate, emp]
            query.endKey = [storeID, fdate, emp, [:]]
        }
        // Query the Summary
        guard let summaryDict = query.loadDict() else {
            return QueryResult()
        }
        // Run the detail query
        query.mapOnly = true
        query.prefetch = true
        if pageSize > 0 { query.limit = pageSize }
        if page > 0 { query.skip = (page - 1) * pageSize }
        let orders: [Order] = query.loadModels()
        var summary = summaryDict
        summary["row_count"] = orders.count
        return QueryResult(rows: orders, summary: QuerySummary(JSON: summary)!)
    }
    
    func load(orders storeID: String, ofEmployee employee: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<Order>] {
        guard storeID.isNotEmpty, employee.isNotEmpty else { return [] }
        
        let query = orderByServerShiftView.createQuery()
        let fdate = fromDate.toString("yyMMdd")
        //        let tdate = toDate.toString("yyMMdd")
        if shift > 0 {
            query.keys = [[storeID, fdate, employee, shift]]
        } else {
            query.startKey = [storeID, fdate, employee]
            query.endKey = [storeID, fdate, employee, [:]]
        }
        // Query the detail first
        query.mapOnly = true
        query.prefetch = true
        let rows: [Order] = query.loadModels()
        // ... then the summary for each shift
        query.groupLevel = 4
        return query.loadMulti()
            .map { (key, value) -> GroupedByShiftQueryResult<Order> in
                let kshift = key[3] as! Int
                let shiftRows = rows.filter { Int($0.shift) == kshift }
                let summary = QuerySummary(JSON: value)!
                return GroupedByShiftQueryResult(shift: kshift, rows: shiftRows, summary: summary)
            }
            .sorted { (lhs, rhs) in lhs.shift > rhs.shift }
    }
}


