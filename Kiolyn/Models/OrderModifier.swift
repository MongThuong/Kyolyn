//
//  OrderModifier.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Hold the modifer/options in an Order Item of either Order or Bill.
class OrderModifier: BaseModel {
    
    /// True if this is created from a global `Modifier`.
    var global = false
    /// True if this is created from a sameline `Modifier`.
    var isSameline = false
    var isNotSameline: Bool { return !isSameline }
    /// True if this is a custom one.
    var custom = false
    /// The Options for this Order Modifier.
    var options: [Option] = []
    var hasOption: Bool { return options.isNotEmpty }    
    
    /// Create with modifier and seleted options.
    ///
    /// - Parameters:
    ///   - modifier: The `Modifier` to create this object from.
    ///   - options: The list of selected `Option`s.
    convenience init(modifier: Modifier, selectedOptions: [Option]) {
        self.init()
        id = modifier.id
        name = modifier.name
        isSameline = modifier.sameline
        global = modifier.global
        custom = modifier.custom
        options = selectedOptions
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        global <- map["global"]
        isSameline <- map["sameline"]
        custom <- map["custom"]
        options <- map["options"]
    }
}
