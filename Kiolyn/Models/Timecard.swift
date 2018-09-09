//
//  Timecard.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent a `Timecard` in the system, each `Employee` has one single `Timecard` document which record all the Clockin/Clockout information of that employee through-out the life-cyle of the application. If the `Timecard` is too big we will back-it-up annually.
class TimeCard: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "timecard" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "etc" }
    /// Return ALL timecard that
    /// 1. Has id
    /// 2. Has merchant id
    /// 3. Not yet deleted
    override class var allMapBlock: CBLMapBlock? {
        return { (doc, emit) in
            // Make sure good inputs
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == documentType,
                let id = doc["id"] as? String, id.isNotEmpty,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty else {
                    return
            }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            emit(storeID, nil)
        }
    }
    
    /// Return all the `TimeLog`s belong to this `TimeCard`.
    var logs: [TimeLog] = []
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        logs <- map["logs"]
    }
}

extension TimeCard {
    /// Create with a employee, employee time card share the same ID with its Employee.
    /// Just like merchant settings share the same ID with its Merchant.
    ///
    /// - Parameters:
    ///   - employee: The `Employee` to create timecard for.
    /// - Returns: `Timecard` for given `Employee`.
    convenience init(employee: Employee) {
        self.init(id: employee.id)
        type = TimeCard.documentType
        channels = ["\(TimeCard.documentIDPrefix)_\(employee.storeID)"]
        merchantID = employee.merchantID
        storeID = employee.storeID
    }
}

/// Type of the time log
///
/// - clockin: Clockin log.
/// - clockout: Clockout log.
enum TimeLogType: String {
    case clockin = "clockin"
    case clockout = "clockout"
}

/// Represent an `Item` inside an `Order`.
class TimeLog: BaseModel {
    /// The Category (id) that this Order Item is created from.
    var logType: TimeLogType = .clockin
    /// The `Reason` (ID) of the clockout (empty for clockin).
    var reason = ""
    /// The `Reason` (Name) of the clockout (empty for clockin).
    var reasonName = ""
    /// The pay rate for the Clockout.
    var rate: Double = 0
    /// The pay rate for the Clockout.
    var payableMinutes: Int = 0
    /// The pay rate for the Clockout.
    var endOfShift = false
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        logType <- (map["log_type"], EnumTransform<TimeLogType>())
        reason <- map["reason"]
        reasonName <- map["reason_name"]
        rate <- map["rate"]
        payableMinutes <- map["payable_minutes"]
        endOfShift <- map["end_of_shift"]
    }
    
    /// Create clockout for given employee inside given store.
    ///
    /// - Parameters:
    ///   - employee: The `Employee` to create for.
    ///   - reason: The `Reason` to create clockout with.
    convenience init(for employee: Employee, with clockoutReason: Reason, id: String? = nil) {
        self.init(id: id ?? BaseModel.newID)
        logType = .clockout
        reason = clockoutReason.id
        reasonName = clockoutReason.name
        endOfShift = clockoutReason.endOfShift
        let pHours = Int(clockoutReason.payableTime[0...1]) ?? 0
        let pMinutes = Int(clockoutReason.payableTime[2...3]) ?? 0
        payableMinutes = pHours * 60 + pMinutes
        rate = employee.payrate
    }
}
