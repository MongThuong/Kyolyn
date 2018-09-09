//
//  Area.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent an `Area` in system, this `Area` is not meant to be updated but getting from a database sync.
class Area: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "area" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "are" }
    /// Return ALL `Area`s that
    /// 1. Has id
    /// 2. Has merchant id
    /// 3. Not yet deleted
    /// 4. Has a name
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
    
    /// Return all the `Table` belong to this `Area`.
    var tables: [Table] = []

    /// True to indicate that this area requires number of guest input.
    var noOfGuestPrompt = false
    /// True to indicate that this area requires customer input.
    var customerInfoPrompt = false
    /// True to indicate that this area requires service fee input.
    var serviceFeePrompt = false
    /// True to indicate that this area is ToGo - Auto Increment
    var isToGo = false
    /// True to indicate that this area is Delivery - Auto Increment
    var isDelivery = false
    var isNotDelivery: Bool { return !isDelivery }

    /// True to indicate that this area is Auto Increment
    var isAutoIncrement: Bool { return isToGo || isDelivery }
    var isNotAutoIncrement: Bool { return !isAutoIncrement }
    
    /// Return the area type in String format for printing.
    var areaOrderType: OrderType {
        if noOfGuestPrompt && !customerInfoPrompt { return .dineIn }
        if customerInfoPrompt { return .delivery }
        return .no
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        tables <- map["layout"]
        noOfGuestPrompt <- map["no_of_guest"]
        customerInfoPrompt <- map["customer_info"]
        serviceFeePrompt <- map["service_fee_prompt"]
        isToGo <- map["togo_auto_increment"]
        isDelivery <- map["delivery_auto_increment"]
    }
}

/// Shapes of `Table`.
enum TableShape: String {
    case ellipse = "ellipse"
    case rectangle = "rectangle"
}

/// Contain display information for a `Table`.
class Table: BaseModel {
    /// Return the shape of table
    var shape: TableShape = .rectangle
    /// The mamimum number of guests can sit at this `Table`.
    var maxGuests: Int = 0
    /// The width of this table.
    var width: CGFloat = 0
    /// The height of this table.
    var height: CGFloat = 0
    /// The angle of this table.
    var angle: CGFloat = 0
    /// The left position of this table.
    var left: CGFloat = 0
    /// The top position of this table.
    var top: CGFloat = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        shape <- (map["type"], EnumTransform<TableShape>())
        maxGuests <- map["ppl"]
        width <- map["width"]
        height <- map["height"]
        angle <- map["angle"]
        left <- map["left"]
        top <- map["top"]
    }
    
    /// The radius x of ellipse table.
    var radiusX: CGFloat { return width / 2 }
    /// The radius Y of ellipse table.
    var radiusY: CGFloat { return height / 2 }
}
