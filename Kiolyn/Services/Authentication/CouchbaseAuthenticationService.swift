//
//  CouchbaseAuth.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/21/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Default implementation of `UserService`
class CouchbaseAuthenticationService: AuthenticationService {
    
    var currentIdentity = BehaviorRelay<Identity?>(value: nil)
    
    func signin(_ store: Store, station: Station, withPasskey passkey: String) -> Single<Identity> {
        let db = ServiceProvider.database
        return db.async {
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
            let settings: Settings = db.load(store.id) ?? db.new(settings: store)
            // Try loading default printer for station, if no is given using the default name
            var defPrinter: Printer? = nil
            if station.printer.isNotEmpty, let printer: Printer = db.load(station.printer) {
                defPrinter = printer
            } else if Configuration.cashierPrinter.isNotEmpty,
                let printer: Printer = db.load(all: station.id, byName: Configuration.cashierPrinter).first {
                defPrinter = printer
            }
            // Set the current identity and return that identity
            let id = Identity(store: store, station: station, employee: employee, settings: settings, defaultPrinter: defPrinter)
            self.currentIdentity.accept(id)
            
            // Fire the countdown logout
            ServiceProvider.idleManager.isActive = true
            
            return id
        }
    }
    
    func verify(passkey: String, havingPermission permission: String) -> Single<Employee?> {
        guard let storeID = ServiceProvider.authService.currentIdentity.value?.store.id else {
            return Single.error(AuthenticationError.lackRequiredPermission)
        }
        let db = ServiceProvider.database
        return db.async {
            // Make sure we got good input
            guard storeID.isNotEmpty, passkey.isNotEmpty, permission.isNotEmpty else {
                throw AuthenticationError.lackRequiredPermission
            }
            // Fetch Employee
            guard let employee: Employee = db.load(employee: storeID, byPasskey: passkey) else {
                throw AuthenticationError.lackRequiredPermission
            }
            // Make sure user has Order permissions
            guard employee.permissions.has(permission: permission) == true else {
                throw AuthenticationError.lackRequiredPermission
            }
            return employee
        }
    }

    func signout() {
        guard let _ = currentIdentity.value else {
            return            
        }
        currentIdentity.accept(nil)
        
        // Fire signedOut signal
        ServiceProvider.idleManager.isActive = false
    }
}
