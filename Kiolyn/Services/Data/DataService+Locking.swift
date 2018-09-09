//
//  DataService+Locking.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum LockingOrderError: LocalizedError {
    case alreadyLocked
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .alreadyLocked: return "The Order is already locked by a different station."
        case .notFound: return "The Order could not be loaded."
        }
    }
}

extension DataService {
    
    /// Lock a single Order for editing.
    ///
    /// - Parameter order: the Order to lock.
    /// - Returns: `Single` of the locking result.
    func lock(order: Order) -> Single<Order?> {
        // Force optional here because we suppose the error must goes through onerror
        return self.lock(orders: [order]).map { $0.first }
    }
    
    /// Lock orders.
    ///
    /// - Parameter orders: the list of order to lock.
    /// - Returns: `Single` of the locking result.
    func lock(orders: [Order]) -> Single<[Order]> {
        guard let stationID = id?.station.id else {
            return Single.just([])
        }
        if self.isMain {
            return self.db.async {
                guard let lockedOrders = try self.lock(orders: orders.map { order in order.id }, forStation: stationID) else {
                    throw LockingOrderError.alreadyLocked
                }
                return lockedOrders.map { properties in Order(JSON: properties)! }
            }
        } else {
            return restClient.lock(orders: orders.map { $0.id })
        }
    }
    
    /// Lock the given Orders with given StationID.
    ///
    /// - Parameters:
    ///     - orders: the orders' ids to be locked.
    ///     - stationID: the station that is requesting for locking.
    /// - Returns: the list of locked orders.
    func lock(orders: [String], forStation stationID: String) throws -> [[String: Any]]? {
        // Ensure good inputs
        guard orders.isNotEmpty, stationID.isNotEmpty else {
            return nil
        }
        var lockedOrders = self.lockedOrders.value
        // First of all, make sure ALL requested orders are not being locked
        // by other station
        let isLocked = orders.any { orderID in
            lockedOrders.contains { (key, value) -> Bool in
                key == orderID && value != stationID
            }
        }
        guard !isLocked else { return nil }
        
        let newOrders = self.db.loadProperties(multi: orders, for: Order.self)
            .filter { order in order != nil }
            .map { order in order! }
        guard newOrders.count == orders.count else {
            i("[DS] Could not fully load all orders for locking")
            return nil
        }
        // Add to locked order list
        for id in orders {
            lockedOrders[id] = stationID
        }
        self.lockedOrders.accept(lockedOrders)
        // Return the orders with force optional
        return newOrders
    }
    
    /// Unlock all orders
    ///
    /// - Returns: Single of the unlocking result.
    func unlockAllOrders() -> Single<Void> {
        guard let stationID = id?.station.id else {
            return Single.just(())
        }
        if self.isMain {
            unlock(allOrders: stationID)
            return Single<Void>.just(())
        } else {
            return restClient.unlockAllOrders().map { _ in }
        }
    }
    
    /// Unlock all order being locked by given stationID.
    ///
    /// - Parameter stationID: the station's id to be unlocking for.
    /// - Returns: Single of the unlocking result
    func unlock(allOrders stationID: String) {
        let lockedOrders = self.lockedOrders.value.filter { (_, lockingStationID) in stationID != lockingStationID }
        self.lockedOrders.accept(lockedOrders)
    }
}
