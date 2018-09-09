//
//  CouchbaseTimeCardService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Default implementation for timecard processing
class DatabaseTimeCardService: TimeCardService {
    var database: Database { return SP.database }
    
    func clockoutReasons(of store: Store) -> Single<[Reason]> {
        return Single<[Reason]>.create { single in
            self.database.async {
                var reasons = [Reason.endOfShiftReason]
                if let settings: Settings = self.database.load(store.id) {
                    reasons.append(contentsOf: settings.clockoutReasons)
                }
                single(.success(reasons))
            }
            return Disposables.create()
        }
    }
    
    private func timecard(for employee: Employee) -> TimeCard? {
        if let timecard: TimeCard = database.load(employee.id) {
            return timecard
        }
        return TimeCard(employee: employee)
    }
    
    func lastTimeLog(for employee: Employee) -> Single<TimeLog?> {
        return database.async {
            guard let timecard: TimeCard = self.database.load(employee.id) else {
                return nil
            }
            return timecard.logs.last
        }
    }
    
    func clockin(store: Store, forEmployee passkey: String) -> Single<(Employee, TimeLog)> {
        return database.async {
            // Load employee
            guard let employee = self.database.load(employee: store.id, byPasskey: passkey) else {
                throw TimeCardError.clockinError(detail: "Invalid passkey.")
            }
            // Load timecard
            guard let timecard = self.timecard(for: employee) else {
                throw TimeCardError.clockinError(detail: "Could not load/create timecard for \(employee.name).")
            }
            // Get last log entry and make sure it is not a clockin
            let lastLogEntry: TimeLog? = timecard.logs.last
            guard lastLogEntry == nil || lastLogEntry!.logType == .clockout else {
                throw TimeCardError.clockinError(detail: "\(employee.name) has already clocked-in.")
            }
            // Append clockin
            let timelog = TimeLog()
            timecard.logs.append(timelog)
            do {
                // Save timecard
                try self.database.save(timecard)
                // ... and return
                return (employee, timelog)
            } catch {
                throw TimeCardError.clockinError(detail: "Error during clocking-in.")
            }
        }
    }
    
    func canClockout(store: Store, forEmployee passkey: String) -> Single<TimeCardError?> {
        return database.async {
            // Load employee
            guard let employee = self.database.load(employee: store.id, byPasskey: passkey) else {
                return TimeCardError.clockoutError(detail: "Invalid passkey.")
            }
            // Load timecard
            guard let timecard = self.timecard(for: employee) else {
                return TimeCardError.clockoutError(detail: "Could not load/create timecard for \(employee.name).")
            }
            // .. then get last log entry and make sure it is not a clockout
            guard let lastLogEntry = timecard.logs.last, lastLogEntry.logType != .clockout else {
                return TimeCardError.clockoutError(detail: "\(employee.name) has not clocked-in yet.")
            }
            return nil
        }
    }
    
    func clockout(store: Store, forEmployee passkey: String, withReason reason: Reason?) -> Single<(Employee, TimeLog)> {
        return database.async {
            // Load employee
            guard let employee = self.database.load(employee: store.id, byPasskey: passkey) else {
                throw TimeCardError.clockoutError(detail: "Invalid passkey.")
            }
            // Load timecard
            guard let timecard = self.timecard(for: employee) else {
                throw TimeCardError.clockoutError(detail: "Could not load/create timecard for \(employee.name).")
            }
            // .. then get last log entry and make sure it is not a clockout
            guard let lastLogEntry = timecard.logs.last, lastLogEntry.logType != .clockout else {
                throw TimeCardError.clockoutError(detail: "\(employee.name) has not clocked-in yet.")
            }
            // not having a reason, must throw a
            guard let reason = reason else {
                throw TimeCardError.requireReason
            }
            // Append clockout
            let timelog = TimeLog(for: employee, with: reason)
            timecard.logs.append(timelog)
            do {
                // Save time card
                try self.database.save(timecard)
                // ... and return
                return (employee, timelog)
            } catch {
                throw TimeCardError.clockoutError(detail: "Error during clocking-in.")
            }
        }
    }
    
    func clockout(all storeID: String) -> [TimeCard] {
        // Load all time card first
        let timecards: [TimeCard] = database.load(all: storeID)
        var updatedTimeCards: [TimeCard] = []
        // Same ID for all clockout
        let clockoutID = BaseModel.newID
        // Go over all timecards to check and add clockout as needed
        for timecard in timecards {
            // Load the last entry
            let lastLogEntry = timecard.logs.last
            // The last entry is already end-of-shift, no further action required
            if lastLogEntry != nil && lastLogEntry!.endOfShift {
                continue
            }
            // Load employee
            guard let employee: Employee = database.load(timecard.id) else {
                i("Employee not found for timecard \(timecard.id), possible that the employee has been deleted.")
                continue;
            }
            // Come down here, means that this timecard need to be updated either by adding
            // clockout (endofshift) or clockin then clockout
            // No last log entry (newly created timecard) or clockout already
            if lastLogEntry == nil || lastLogEntry!.logType == .clockout {
                timecard.logs.append(TimeLog(id: clockoutID))
            }
            // Now clock this user out with EndOfShift reason
            timecard.logs.append(TimeLog(for: employee, with: Reason.endOfShiftReason, id: clockoutID))
            // Add for updates
            updatedTimeCards.append(timecard)
        }
        return updatedTimeCards
    }
}
