//
//  CouchbaseDatabase+ByTotalReport.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Report row for total (By Payment Type and By Area) report.
class TotalReportRow: BaseModel {
    var shift: Int = 0
    var count: Int = 0
    var tip: Double = 0
    var total: Double = 0
    var totalWithTip: Double { return total + tip }
    override func mapping(map: Map) {
        super.mapping(map: map)
        shift <- map["shift"]
        count <- map["count"]
        tip <- map["tip"]
        total <- map["total"]
    }
}

/// Report row for total report by payment type.
class PaymentTypeTotalReportRow: TotalReportRow {
    var transType = ""
    var cardType = ""
    var isDetail: Bool { return cardType.isNotEmpty }
    var displayName: String {
        if isDetail { return cardType.uppercased() }
        guard transType.isNotEmpty else { return "" }
        
        let parts = transType.components(separatedBy: "$")
        
        var displayValue = ""
        var custom = false
        let type = parts[0]
        switch type {
        case TransactionType.cash.rawValue: displayValue = "CASH"
        case TransactionType.creditSale.rawValue: displayValue = "CREDIT CARD"
        case TransactionType.creditVoid.rawValue: displayValue = "VOID"
        case TransactionType.creditRefund.rawValue: displayValue = "REFUND"
        case TransactionType.creditForce.rawValue: displayValue = "FORCE"
        case TransactionType.custom.rawValue:
            custom = true
            if parts.count > 2 { displayValue = parts[2] }
        default: return ""
        }
        
        if custom {
            if parts.count > 4 { displayValue += " - \(parts[4])" }
        } else if parts.count > 2 { displayValue += " - \(parts[2])" }
        
        return displayValue.uppercased()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        transType <- map["trans_type"]
        cardType <- map["card_type"]
    }
}

/// Report row for area summary report.
class AreaTotalReportRow: TotalReportRow {
    var area = ""
    var areaName = ""
    var driver = ""
    var driverName = ""
    var delivery = false
    var isDetail: Bool { return delivery && driver.isNotEmpty }
    var displayName: String {
        return (isDetail
            ? (driverName.isNotEmpty ? driverName : "NO DRIVER")
            : areaName)
            .uppercased()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        area <- map["area"]
        areaName <- map["area_name"]
        driver <- map["driver"]
        driverName <- map["driver_name"]
        delivery <- map["delivery"]
    }
}

extension CouchbaseDatabase {
    func load(byPaymentTypeReport storeID: String, fromDate: Date, toDate: Date, shift: Int, includeCardType: Bool) -> ReportQueryResult<PaymentTypeTotalReportRow> {
        guard storeID.isNotEmpty else { return ReportQueryResult() }
        
        let query = transactionByTypeView.createQuery()
        
        let fdate = fromDate.toString("yyMMdd")
        let tdate = toDate.toString("yyMMdd")
        if fdate == tdate && shift > 0 {
            query.startKey = [storeID, fdate, shift]
            query.endKey = [storeID, fdate, shift, [:]]
        } else {
            query.startKey = [storeID, fdate]
            query.endKey = [storeID, tdate, [:], [:]]
        }
        
        // Query the Summary
        query.groupLevel = 0
        guard let summaryDict = query.loadDict() else {
            return ReportQueryResult()
        }
        // Run the grouped query
        query.groupLevel = includeCardType ? 5 : 4
        let rows = query.loadMulti().map { (key, value) -> PaymentTypeTotalReportRow in
            var nvalue = value
            nvalue["shift"] = key[2] as! Int
            nvalue["trans_type"] = key[3] as! String
            if includeCardType {
                nvalue["card_type"] = key[4] as! String
            }
            return PaymentTypeTotalReportRow(JSON: nvalue)!
        }
        var summary = summaryDict
        summary["row_count"] = rows.count
        return ReportQueryResult<PaymentTypeTotalReportRow>(rows: rows, summary: ReportQuerySummary(JSON: summary)!)
    }
    
    func load(byPaymentTypeReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<PaymentTypeTotalReportRow>] {
        guard storeID.isNotEmpty else { return [] }
        
        let query = transactionByTypeView.createQuery()
        
        let fdate = fromDate.toString("yyMMdd")
        let tdate = toDate.toString("yyMMdd")
        if fdate == tdate && shift > 0 {
            query.startKey = [storeID, fdate, shift]
            query.endKey = [storeID, fdate, shift, [:]]
        } else {
            query.startKey = [storeID, fdate]
            query.endKey = [storeID, tdate, [:], [:]]
        }
        
        // Query the detail first
        query.groupLevel = 5
        let rows = query.loadMulti().map { (key, value) -> PaymentTypeTotalReportRow in
            var nvalue = value
            nvalue["shift"] = key[2] as! Int
            nvalue["trans_type"] = key[3] as! String
            nvalue["card_type"] = key[4] as! String
            return PaymentTypeTotalReportRow(JSON: nvalue)!
        }
        // ... then the summary for each shift
        query.groupLevel = 3
        return query.loadMulti().map { (key, value) -> GroupedByShiftQueryResult<PaymentTypeTotalReportRow> in
            let kshift = key[2] as! Int
            let shiftRows = rows.filter { $0.shift == kshift }
            let summary = QuerySummary(JSON: value)!
            return GroupedByShiftQueryResult(shift: kshift, rows: shiftRows, summary: summary)
            }.sorted { (lhs, rhs) in lhs.shift > rhs.shift }
    }
    
    func load(byAreaReport storeID: String, fromDate: Date, toDate: Date, shift: Int) -> ReportQueryResult<AreaTotalReportRow> {
        guard storeID.isNotEmpty else { return ReportQueryResult() }
        
        let query = orderByShiftAreaDriverView.createQuery()
        
        let fdate = fromDate.toString("yyMMdd")
        let tdate = toDate.toString("yyMMdd")
        if fdate == tdate && shift > 0 {
            query.startKey = [storeID, fdate, shift]
            query.endKey = [storeID, fdate, shift, [:], [:]]
        } else {
            query.startKey = [storeID, fdate]
            query.endKey = [storeID, tdate, [:], [:], [:]]
        }
        // Query the Summary
        query.groupLevel = 0
        guard let summaryDict = query.loadDict() else {
            return ReportQueryResult()
        }
        // Run the grouped query
        query.groupLevel = 5
        let rows = query.loadMulti().map { (key, value) -> AreaTotalReportRow in
            var nvalue = value
            nvalue["shift"] = key[2] as! Int
            nvalue["area"] = key[3] as! String
            nvalue["driver"] = key[4] as! String
            return AreaTotalReportRow(JSON: nvalue)!
        }
        var summary = summaryDict
        summary["row_count"] = rows.count
        return ReportQueryResult<AreaTotalReportRow>(rows: rows, summary: ReportQuerySummary(JSON: summary)!)
    }
    
    func load(byAreaReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<AreaTotalReportRow>] {
        guard storeID.isNotEmpty else { return [] }
        
        let query = orderByShiftAreaDriverView.createQuery()
        
        let fdate = fromDate.toString("yyMMdd")
        let tdate = toDate.toString("yyMMdd")
        if fdate == tdate && shift > 0 {
            query.startKey = [storeID, fdate, shift]
            query.endKey = [storeID, fdate, shift, [:], [:]]
        } else {
            query.startKey = [storeID, fdate]
            query.endKey = [storeID, tdate, [:], [:], [:]]
        }
        // Query the detail first
        query.groupLevel = 5
        let rows = query.loadMulti().map { (key, value) -> AreaTotalReportRow in
            var nvalue = value
            nvalue["shift"] = key[2] as! Int
            nvalue["area"] = key[3] as! String
            nvalue["driver"] = key[4] as! String
            return AreaTotalReportRow(JSON: nvalue)!
        }
        // ... then the summary for each shift
        query.groupLevel = 3
        return query.loadMulti().map { (key, value) -> GroupedByShiftQueryResult<AreaTotalReportRow> in
            let kshift = key[2] as! Int
            let shiftRows = rows.filter { $0.shift == kshift }
            let summary = QuerySummary(JSON: value)!
            return GroupedByShiftQueryResult(shift: kshift, rows: shiftRows, summary: summary)
            }.sorted { (lhs, rhs) in lhs.shift > rhs.shift }
    }
}
