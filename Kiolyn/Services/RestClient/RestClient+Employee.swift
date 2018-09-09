//
//  RestClient+Employee.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension RestClient {
    
    /// Load the default driver from Main.
    ///
    /// - Returns: Single of the loading result.
    func loadDefaultDriver() -> Single<Employee?> {
        guard let storeID = store?.id else {
            return Single.just(nil)
        }
        return load(model: "store/\(storeID)/driver/default")
    }

    /// Load all drivers belong to current Store from Main.
    ///
    /// - Returns: Single of the loading result.
    func loadDrivers() -> Single<[Employee]> {
        guard let storeID = store?.id else {
            return Single.just([])
        }
        return load(multiModel: "store/\(storeID)/driver")
    }

    /// Load an employee from given Store with given passkey.
    ///
    /// - Parameters:
    ///   - storeID: the Store to load for.
    ///   - passkey: the passkey to load for.
    /// - Returns: Single of the loading result.
    func load(employee storeID: String, passkey: String) -> Single<Employee?> {
        guard let storeID = store?.id else {
            return Single.just(nil)
        }
        return load(model: "store/\(storeID)/employee/\(passkey)")
    }
}
