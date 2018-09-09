//
//  Identity.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Contain information about a working session for a User. The name is not obvious, it is more about a working session, however we inherit this from .NET app which Identity is the MUST-USE name, thus keep the same name for consistency.
class Identity: Mappable {
    /// The `Store` that this session will be working with.
    var store: Store!
    /// The `Station` information that give description about the current running machine (iPad).
    var station: Station!
    /// The `Employee` information that is logging in.
    var employee: Employee!
    /// The `Settings` to be used for ordering.
    var settings: Settings!
    /// The default `Printer` for current identity
    var defaultPrinter: Printer?
    /// The default `Printer` for current identity
    var ccDevice: CCDevice?
    /// Create a working session with given parameters.
    ///
    /// - Parameters:
    ///   - store: The logged in `Store`.
    ///   - station: The logged in `Station`.
    ///   - employee: The logged in `Employee`.
    ///   - settings: The logged in `Settings`.
    init(store: Store, station: Station, employee: Employee, settings: Settings, defaultPrinter: Printer? = nil) {
        self.store = store
        self.station = station
        self.employee = employee
        self.settings = settings
        self.defaultPrinter = defaultPrinter
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        employee <- map["employee"]
        settings <- map["settings"]
        defaultPrinter <- map["default_printer"]
        ccDevice <- map["ccdevice"]
    }
}
