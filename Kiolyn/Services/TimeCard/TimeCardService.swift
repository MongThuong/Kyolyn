//
//  TimeCardService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/21/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift


/// Time card service related error.
enum TimeCardError: LocalizedError {
    case clockinError(detail: String)
    case clockoutError(detail: String)
    case requireReason
    /// User friendly description
    var errorDescription: String? {
        switch self {
        case let .clockinError(detail): return detail
        case let .clockoutError(detail): return detail
        default: return ""
        }
    }
}

/// Provice all timecard related processing
protocol TimeCardService {
    
    /// Return all the clockout reason for a given store.
    ///
    /// - Parameter store: The `Store` to get `Reason for`.
    /// - Returns: `Single` of the clockout `Reason`.
    func clockoutReasons(of store: Store) -> Single<[Reason]>

    /// Load the last time log of an employee.
    ///
    /// - Parameter employee: the `Employee` to load for.
    /// - Returns: the last `TimeLog` entry of queried `Employee`.
    func lastTimeLog(for employee: Employee) -> Single<TimeLog?>
    
    /// Add a clockin entry for given passkey.
    ///
    /// - Parameters:
    ///   - store: the store to check with.
    ///   - passkey: the employee's passkey
    /// - Returns: `Single` of the clocking result
    func clockin(store: Store, forEmployee passkey: String) -> Single<(Employee, TimeLog)>
    
    /// Verify if employee can do clockout.
    ///
    /// - Parameters:
    ///   - store: The `Store` to clockin
    ///   - passkey: The passkey of employee.
    /// - Returns: `Single` of the clock-out checking error.
    func canClockout(store: Store, forEmployee passkey: String) -> Single<TimeCardError?>
    
    /// Add a clockout entry for given employee.
    ///
    /// - Parameters:
    ///   - store: The `Store` to clockin
    ///   - passkey: The passkey of employee.
    ///   - reason: The `Reason` for clocking out.
    /// - Returns: `Single` of the clocking result
    func clockout(store: Store, forEmployee passkey: String, withReason reason: Reason?) -> Single<(Employee, TimeLog)>
    
    /// Called to clock all employees out. Normally this should be called upon closing a shift.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to clockout all employee for.
    /// - Returns: The list of `TimeCard` that got modified.
    func clockout(all storeID: String) -> [TimeCard]
}
