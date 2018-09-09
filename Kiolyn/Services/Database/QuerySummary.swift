//
//  QuerySummary.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Summary of a query.
class QuerySummary: BaseModel {
    var rowCount: Int = 0
    var count: Int = 0
    var tip: Double = 0
    var total: Double = 0
    var totalWithTip: Double { return tip + total }
    
    // MARK: EMPLOYEE REPORT SUMMARY
    var opening: Int = 0
    var closing: Int  = 0
    
    // MARK: SHIFT&DAY
    var tax: Double = 0
    var discount: Double = 0
    var serviceFee: Double = 0
    var serviceFeeTax: Double = 0
    var guests: Int = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        rowCount <- map["row_count"]
        count <- map["count"]
        // Update with count
        rowCount = rowCount > 0 ? rowCount : count
        tip <- map["tip"]
        total <- map["total"]
        opening <- map["opening"]
        closing <- map["closing"]
        tax <- map["tax"]
        discount <- map["discount"]
        serviceFee <- map["service_fee"]
        serviceFeeTax <- map["service_fee_tax"]
        guests <- map["guests"]
    }
    
    convenience init(count: Int) {
        self.init()
        rowCount = count
        self.count = count
    }
}
