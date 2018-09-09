//
//  Discount.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/16/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Discount detail information.
class Discount: BaseModel {
    /// Discount value in percentage
    var percent: Double = 0
    /// Percent might be adjusted during ordering, so this value must be used for calculation and not the `percent`.
    var adjustedPercent: Double = 0
    /// Any percentage adjustment to discount must pair with a reason.
    var adjustedReason: String = ""
    
    /// Return the value used for calculation.
    var finalPercent: Double {
        return adjustedPercent > 0 ? adjustedPercent : percent
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        percent <- map["percent"]
        adjustedPercent <- map["adjusted_percent"]
        adjustedReason <- map["adjusted_reason"]
    }
    
    static let noDiscountID = "no"
    
    /// No Discount discount object.
    static var noDiscount: Discount {
        let discount = Discount(id: noDiscountID)
        discount.name = "No Discount"
        return discount
    }
}
