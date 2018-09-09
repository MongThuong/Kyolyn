//
//  Modifier.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent a `Modifier` in system, this `Modifier` is not meant to be updated but getting from a Sync Session API call.
class Modifier: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "modifier" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "mod" }
    /// Return ALL modifier that
    /// 1. Has id
    /// 2. Has merchant id
    /// 3. Not yet deleted
    /// 4. Not hidden
    /// 5. Has a name
    override class var allMapBlock: CBLMapBlock? {
        return { (doc, emit) in
            // Make sure good inputs
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == documentType,
                let id = doc["id"] as? String, id.isNotEmpty,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                // having a good name
                let name = doc["name"] as? String, name.isNotEmpty else {
                    return
            }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            emit(storeID, nil)
        }
    }
 
    /// True if this modifier is a global one.
    var global = false
    var isNotGlobal: Bool { return !global }
    /// True if this modifier is a required one.
    var required = false
    var notRequired: Bool { return !required }
    /// True if this modifier is a required one.
    var sameline = false
    /// True if this modifier allow multiple options selection.
    var multiple = false
    /// Return all the available `Option`s of this `Modifier`.
    var options: [Option] = []
    /// Append a `*` to name if modifier is a required one
    var nameWithRequired: String { return required ? "\(name) *" : name }
    /// Whether this modifier is a custom one or not.
    var custom = false
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        global <- map["global"]
        required <- map["required"]
        sameline <- map["sameline"]
        multiple <- map["multiple"]
        options <- map["options"]
        custom <- map["custom"]
    }
}

extension Modifier {
    /// Create new custom modifier (won't be saved - just for in memory usage and ordering)
    ///
    /// - Returns: the custom modifier.
    /// - Throws: creating model error.
    convenience init(custom option: Option) {
        self.init()
        name = "Custom"
        options = [option]
        custom = true
    }
}


/// Sync session object, stored inside local Store document after calling to API server for authentication.
class Option: GridItemModel {
    /// The price of this option.
    var price: Double = 0
    
    /// Create custom option with name and price.
    ///
    /// - Parameters:
    ///   - name: Name of the custom Option.
    ///   - price: Price of the custom Option.
    convenience init(name: String, price: Double) {
        self.init()
        type = "option"
        self.name = name
        self.price = price
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        price <- map["price"]
    }
}
