//
//  Database+Reports.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/11/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Common based report summary
class ReportQuerySummary: QuerySummary {
    /// For summary of report queries that have shifts.
    var shifts: [Int] = []
    /// For summary of report queries that have servers.
    var servers: [String] = []
    /// For summary of report queries that have area.
    var areas: [String] = []
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        shifts <- map["shifts"]
        servers <- map["servers"]
        areas <- map["areas"]
    }
}

/// Specific report query result for displaying filters.
class ReportQueryResult<R: Mappable>: QueryResult<R> {
    var reportSummary: ReportQuerySummary { return summary as! ReportQuerySummary }
    init(rows: [R], summary: ReportQuerySummary) {
        super.init(rows: rows, summary: summary)
    }
    required convenience init(rows: [R] = []) {
        self.init(rows: rows, summary: ReportQuerySummary())
    }
    required convenience init?(map: Map) {
        self.init()
    }
}

/// Query Result which grouped by Shift, this is mostly for priting.
class GroupedByShiftQueryResult<R: Mappable> : QueryResult<R> {
    var shift: Int = 0
    init(shift: Int, rows: [R], summary: QuerySummary) {
        super.init(rows: rows, summary: summary)
        self.shift = shift
    }
    required init(rows: [R] = []) {
        super.init(rows: rows)
    }
    required convenience init?(map: Map) {
        self.init()
    }
}

typealias Sum = (Any?, Any?) -> Any
let DSum: Sum = { (lhs, rhs) -> Any in (lhs as? Double ?? 0) + (rhs as? Double ?? 0) }
let ISum: Sum = { (lhs, rhs) -> Any in (lhs as? Int ?? 0) + (rhs as? Int ?? 0) }

// MARK: - Array of Dictionary/KVP extension
extension Array where Element == [String: Any] {
    /// Sum a list of object/dictionary base on the listed keys/types
    ///
    /// - Returns: The sum of listed keys/types.
    func sum(fields: [(String, Sum)]) -> Element {
        return self.reduce([:], { (acc, item) -> Element in
            var reduced = Element()
            for (key, sum) in fields {
                reduced[key] = sum(acc[key], item[key])
            }
            return reduced
        })
    }

    /// Sum and map to target name.
    ///
    /// - Returns: The sum of listed keys/types.
    func sum(fields: [(String, String, Sum)], filter: ((Element) -> Bool) = { _ in true }) -> Element {
        return self.reduce([:], { (acc, item) -> [String: Any] in
            // Filter out items not matching filter condition
            guard filter(item) else { return acc }
            var reduced = Element()
            for (key, targetKey, sum) in fields {
                reduced[targetKey] = sum(acc[targetKey], item[key])
            }
            return reduced
        })
    }
}
