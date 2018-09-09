//
//  Auth.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/21/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Provide authenticating services.
class AuthenticationService {
    
    /// Contain the current identity, this must be set on signin and cleared on signout.
    var currentIdentity = BehaviorRelay<Identity?>(value: nil)
    
    /// Verify if passkey can signin with store/station.
    ///
    /// - Parameters:
    ///   - store: the Store to signin with.
    ///   - station: the Station to signin with.
    ///   - passkey: the passkey to sigin with.
    /// - Returns: `Single` of the signin identity.
    func verify(signin store: Store, station: Station, withPasskey passkey: String) throws -> Identity {
        let db = SP.database
        // Make sure we got good input
        guard passkey.isNotEmpty else {
            throw AuthenticationError.invalidPasskey
        }
        // Fetch Employee, make sure employee can be found by passkey
        guard let employee: Employee = db.load(employee: store.id, byPasskey: passkey) else {
            throw AuthenticationError.invalidPasskey
        }
        // Make sure user has Order permissions
        guard employee.permissions.order == true else {
            throw AuthenticationError.lackOrderPermission
        }
        // Now, if user is required to clockin first, we need to make sure they are already clockedin
        if employee.permissions.mustClockin {
            guard let timecard: TimeCard = db.load(employee.id),
                let lastTimeLog = timecard.logs.last,
                lastTimeLog.logType == .clockin else {
                    throw AuthenticationError.requiredClockin
            }
        }
        // Load store settings, if no settings found (possibly an old store before the time of Settings, or some Store go created without a proper Settings), we need to create a temporary Settings for the Store.
        let settings: Settings = db.load(store.id) ?? Settings(store: store)
        // Try loading default printer for station, if no is given using the default name
        var defPrinter: Printer? = nil
        if station.printer.isNotEmpty, let printer: Printer = db.load(station.printer) {
            defPrinter = printer
        } else if Configuration.cashierPrinter.isNotEmpty,
            let printer: Printer = db.load(all: station.id, byName: Configuration.cashierPrinter).first {
            defPrinter = printer
        }
        // Set the current identity and return that identity
        return Identity(store: store, station: station, employee: employee, settings: settings, defaultPrinter: defPrinter)
    }
    
    /// Signin remotely/locally using store/station and passkey.
    ///
    /// - Parameters:
    ///   - store: the Store to signin with.
    ///   - station: the Station to signin with.
    ///   - passkey: the passkey to sigin with.
    /// - Returns: `Single` of the signin identity.
    func signin(_ store: Store, station: Station, withPasskey passkey: String) -> Single<Identity> {
        return SP.database.async {
            let id = try self.verify(signin: store, station: station, withPasskey: passkey)
            self.signin(id: id)
            return id
        }
    }
    
    /// Set the ID and login user.
    ///
    /// - Parameter id: the user id.
    func signin(id: Identity) {
        currentIdentity.accept(id)
        
        // start countdown
        SP.idleManager.isActive = true
    }
    
    /// Check if given passkey/employee has the given permission.
    ///
    /// - Parameters:
    ///   - storeID: The store `id` to log in with.
    ///   - passkey: The employee passkey.
    ///   - permission: The permission to check for.
    /// - Returns: The Single of `Identity` (`Employee`) if the given passkey matches with a employee who possess the given permission
    func verifyAsync(passkey: String, havingPermission permission: String) -> Single<Employee?> {
        return SP.database.async {
            guard let store = self.currentIdentity.value?.store else {
                return nil
            }
            return self.verify(passkey: passkey, havingPermission: permission, inStore: store)
        }
    }
    
    /// Check if given passkey/employee has the given permission.
    ///
    /// - Parameters:
    ///   - storeID: The store `id` to log in with.
    ///   - passkey: The employee passkey.
    ///   - permission: The permission to check for.
    /// - Returns: The `Identity` (`Employee`) if the given passkey matches with a employee who possess the given permission
    func verify(passkey: String, havingPermission permission: String, inStore store: Store) -> Employee? {
        guard passkey.isNotEmpty, permission.isNotEmpty,
            // Employee exists
            let employee: Employee = SP.database.load(employee: store.id, byPasskey: passkey),
            // ... and having the required permission
            employee.permissions.has(permission: permission) else {
            return nil
        }
        return employee
    }

    /// Signout by clearing the stored identity and notify listener on this important event.
    func signout() {
        guard let _ = currentIdentity.value else {
            return
        }
        currentIdentity.accept(nil)
        
        // stop countdown
        SP.idleManager.isActive = false
    }
}

/// All errors relating to user authentication.
enum AuthenticationError: UInt, LocalizedError, Equatable {
    case invalidPasskey = 3
    case lackOrderPermission = 4
    case lackRequiredPermission = 5
    case requiredClockin = 6
    /// User friendly description
    var errorDescription: String? {
        switch self {
        case .invalidPasskey:
            return "Invalid passkey."
        case .lackOrderPermission:
            return "User does not have Order permisison."
        case .lackRequiredPermission:
            return "User does not have required permisison."
        case .requiredClockin:
            return "User must clock-in first."
        }
    }
    
    public static func ==(lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Convenient properties
extension AuthenticationService {
    var isSignedOut: Bool { return self.currentIdentity.value == nil }
    var isMain: Bool? { return self.station?.main }
    var store: Store? { return self.currentIdentity.value?.store }
    var employee: Employee? { return self.currentIdentity.value?.employee }
    var settings: Settings? { return self.currentIdentity.value?.settings }
    var station: Station? { return self.currentIdentity.value?.station }
    var defaultPrinter: Printer? { return self.currentIdentity.value?.defaultPrinter }
}
