//
//  Station.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Type of `Station`.
enum StationType: String {
    case ipad = "iPad"
    case pc = "PC"
}

/// Transform everything to lowercase
let objectMapperLowercaseTransform = TransformOf<String, String>(fromJSON: { (value: String?) -> String? in
    value?.lowercased()
}) { (value: String?) -> String? in
    value?.lowercased()
}

/// Represent a `Station` in system, this `Station` is not meant to be updated but getting from a Sync Session API call.
class Station: BaseModel {
    // The mac that will always return the Main Station
    static var passthroughMac = "705a0f1792e5"
    /// Document type of this class
    override class var documentType: String { return "station" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "stn" }
    
    // Location of this station
    var location = ""
    // Credit card device bound to this station
    var ccdevice = ""
    // Default printer bound to this station
    var printer = ""
    // The type of this station
    var stationType: StationType = .pc
    // True if this station is enabled or not
    var enabled = false
    // True if this station is the MAIN station.
    var main = false
    /// This station mac address
    var macAddress = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        location <- map["location"]
        ccdevice <- map["ccdevice"]
        printer <- map["printer"]
        stationType <- (map["station_type"], EnumTransform<StationType>())
        enabled <- map["enabled"]
        main <- map["main"]
        macAddress <- (map["mac_address"], objectMapperLowercaseTransform)
    }
}
