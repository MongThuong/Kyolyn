//
//  DataService+Employee.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/8/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension DataService {
    
    /// Load current Store's default driver
    ///
    /// - Returns: `Single` of the default driver.
    func loadDefaultDriver() -> Single<Employee?> {
        if self.isMain {
            return self.db.async {
                self.db.load(defaultDriver: self.store.id)
            }
        } else {
            return restClient.loadDefaultDriver()
        }
    }
    
    /// Load all drivers.
    ///
    /// - Parameter storeID: the `Store` to load from.
    /// - Returns: the list of `Driver`s of the given `Store`.
    func loadAllDrivers() -> Single<[Employee]> {
        if self.isMain {
            return self.db.async {
                self.db.load(drivers: self.store.id)
            }
        } else {
            return restClient.loadDrivers()
        }
    }
}
