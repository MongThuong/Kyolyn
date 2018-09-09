//
//  Shift.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent a `Shift` in the system, `Shift` info must be logged to all documents created during `Shift`. Only one active `Shift` is allowed across stations.
class Shift: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "shift" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "shift" }
    
    /// The index of this shift, reset to 1 at day changed.
    var index: UInt = 0    
    /// The current order number of this shift, reset to 1 on new shift.
    var orderNum: UInt = 0
    /// The current transaction number of this shift, reset to 1 no new shift.
    var transNum: UInt64 = 0
    /// Id of employee who opens this shift.
    var openedBy = ""
    /// Name of employee who opens this shift.
    var openedByName = ""
    /// Id of employe who closes this shift.
    /// Name of employee who opens this shift.
    var closedBy = ""
    /// Name of employee who closes this shift.
    var closedByName = ""
    /// Time when this shift is closed.
    var closedAt = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        index <- map["index"]
        orderNum <- map["order_num"]
        transNum <- map["trans_num"]
        openedBy <- map["opened_by"]
        openedByName <- map["opened_by_name"]
        closedBy <- map["closed_by"]
        closedByName <- map["closed_by_name"]
        closedAt <- map["closed_at"]
    }
}

extension Shift {
    
    /// Create new shift for store, by employee and given index.
    ///
    /// - Parameters:
    ///   - store: The `Store` to create for.
    ///   - employee: The `Employee` who open new shift.
    ///   - index: The shift index. This value is reset at a new day.
    /// - Returns: The new `Shift`.
    convenience init(inStore store: Store, byEmployee employee: Employee, index idx: UInt){
        self.init()
        type = Shift.documentType
        merchantID = store.merchantID
        storeID = store.id
        channels = [ store.id, "ord_\(store.id)" ]
        index = idx
        orderNum = 0
        transNum = 0
        openedBy = employee.id
        openedByName = employee.name
    }
}



