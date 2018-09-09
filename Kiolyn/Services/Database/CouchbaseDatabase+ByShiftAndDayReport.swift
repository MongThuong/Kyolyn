//
//  CouchbaseDatabase+ByShiftAndDayReport.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Name and Value row (used for Shift&Day report).
class NameValueReportRow: Mappable, Equatable {
    /// Row name.
    var name = ""
    /// Already formatted value.
    var value = ""
    /// The type of row
    var rowType = ""

    init(name: String, value: String = "", rowType: String = "normal") {
        self.name = name
        self.value = value
        self.rowType = rowType
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        value <- map["value"]
        rowType <- map["row_type"]
    }

    public static func ==(lhs: NameValueReportRow, rhs: NameValueReportRow) -> Bool {
        return false
    }
}

extension CouchbaseDatabase {
    func load(shiftSummary storeID: String, fromDate: Date, toDate: Date, shift: Int) -> QuerySummary {
        guard storeID.isNotEmpty else {
            return QuerySummary()
        }
        
        let query = orderByShiftServerView.createQuery()
        let fdate = fromDate.toString("yyMMdd")
        let tdate = toDate.toString("yyMMdd")
        if fdate == tdate && shift > 0 {
            query.startKey = [storeID, fdate, shift]
            query.endKey = [storeID, fdate, shift, [:]]
        } else {
            query.startKey = [storeID, fdate]
            query.endKey = [storeID, tdate, [:], [:]]
        }
        
        do {
            if let summary = try query.run().nextRow()?.value as? [String:Any],
                let querySummary = QuerySummary(JSON: summary) {
                return querySummary
            }
        } catch {
            e(error)
        }
        return QuerySummary()
    }
}
