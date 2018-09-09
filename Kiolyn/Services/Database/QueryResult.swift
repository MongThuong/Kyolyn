//
//  QueryResult.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Result of a query with rows and summary.
class QueryResult<R: Mappable>: Mappable {
    /// The rows of the query.
    var rows: [R]
    /// Summary of this query
    var summary: QuerySummary
    
    required init?(map: Map) {
        rows = []
        summary = QuerySummary(count: 0)
    }
    
    required init(rows: [R] = []) {
        self.rows = rows
        summary = QuerySummary(count: rows.count)
    }
    
    init(rows: [R], summary: QuerySummary) {
        self.rows = rows
        self.summary = summary
    }
    
    func mapping(map: Map) {
        rows <- map["rows"]
        summary <- map["summary"]
    }
}
