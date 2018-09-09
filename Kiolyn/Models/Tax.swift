//
//  Tax.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/16/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Tax detail information.
class Tax: BaseModel {
    /// Tax value in percentage.
    var percent: Double = 0
    /// True if this tax is a default one.
    var isDefault = false
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        percent <- map["percent"]
        isDefault <- map["default"]
    }
    
    static let noTaxID = "no"
    /// No Tax tax object.
    static var noTax: Tax {
        let tax = Tax(id: noTaxID)
        tax.name = "No Tax"
        return tax
    }
}

