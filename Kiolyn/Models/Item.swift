//
//  Item.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent an `Item` in system, this `Item` is not meant to be updated but getting from a database sync.
class Item: GridItemModel {
    /// Document type of this class
    override class var documentType: String { return "item" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "it" }
    
    /// The category that this item belongs to.
    var category = ""
    /// The Name2 to be printed to Kitchen and Check receipt.
    var name2 = ""
    /// The language of Name2
    var name2Language = ""
    /// The price of this item.
    var price: Double = 0
    /// The list of printers to print this item to upon Submitting.
    var printers: [BaseModel] = []
    /// The list of modifiers belongs to this item.
    var modifiers: [ModifierRef] = []
    /// True if this item is an created dynamically.
    var isOpenItem = false
    /// Image item.
    var image: Image?

    /// True is this item has image
    var hasImage: Bool {
        if let file = image?.file, !file.isEmpty { return true }
        else { return false }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name2 <- map["name2"]
        name2 <- map["name2"]
        category <- map["category"]
        name2 <- map["name2"]
        name2Language <- map["name2_lang"]
        price <- map["price"]
        printers <- map["printers"]
        modifiers <- map["modifiers"]
        isOpenItem <- map["isopenitem"]
        image <- map["image"]
    }
}

class ModifierRef: BaseModel {
    /// The modifier is required or not
    var required = false
    /// The modifier is sameline or not
    var sameline = false
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        required <- map["required"]
        sameline <- map["sameline"]
    }
}
