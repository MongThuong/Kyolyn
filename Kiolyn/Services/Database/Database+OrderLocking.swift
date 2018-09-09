//
//  Database+OrderLocking.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

let lockedOrdersDocPrefix = "lo_"

extension Database {
    
    /// If no `Station` is given, return ALL the locked orders, otherwise return only the
    /// orders locked by given station.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - stationID: The `Station` to load for.
    /// - Returns: The list of locked orders (each locked order return as an entry).
    func loadLockedOrders(_ storeID: String, by stationID: String? = nil) -> [String: Any]? {
        if let stationID = stationID, stationID.isNotEmpty {
            return mapLockedOrder(storeID) { pro in
                    pro.filter{ (key, value) -> Bool in
                        guard let lockedInfo = value as? [String: Any],
                            let lockingStationID = lockedInfo["station"] as? String,
                            lockingStationID == stationID else { return false }
                        return true
                    }.dictionary()
                }
        } else { return mapLockedOrder(storeID) { $0 } }
    }
    
    /// Return locked `Order`s by station different from the querying one.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - stationID: The `Station` to load for.
    /// - Returns: The list of locked orders (each locked order return as an entry).
    func loadLockedOrders(_ storeID: String, notBy stationID: String) -> [String: Any]? {
        guard stationID.isNotEmpty else { return nil }
        return mapLockedOrder(storeID) { pro in
            pro.filter{ (key, value) -> Bool in
                guard let lockedInfo = value as? [String: Any],
                    let lockingStationID = lockedInfo["station"] as? String,
                    lockingStationID != stationID else { return false }
                    return true
                }.dictionary()
        }
    }
    
    /// Return locked info (Station name, Employee name).
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - orderID: The `Order` to load for.
    /// - Returns: The locked detail.
    func loadLockedOrderInfo(_ storeID: String, order orderID: String) -> (String, String)? {
        guard orderID.isNotEmpty else { return nil }
        return mapLockedOrder(storeID) { pro in
            guard let lockedInfo = pro[orderID] as? [String: Any] else { return nil }
            return (lockedInfo["station_name"] as? String ?? "",
                    lockedInfo["current_employee"] as? String ?? "")
        }
    }
    
    /// Check if the given Station is already locking the give Orders' Id/Revision.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to check for.
    ///   - stationID: The `Station` to check for.
    ///   - orders: The pairs (Order Id/Revision).
    /// - Returns: `true` if all the given `Order`s is being locked by given `Station` at checked `Revision`s.
    func areLocked(_ storeID: String, by stationID: String, orders: [String: String]) -> Bool {
        guard stationID.isNotEmpty, orders.isNotEmpty else { return false }
        return mapLockedOrder(storeID) { pro in
            orders.all { (key, rev) -> Bool in
                guard let lockedInfo = pro[key] as? [String: Any],
                    let lockedStationID = lockedInfo["station"] as? String, lockedStationID == stationID,
                    let lockedRev = lockedInfo["rev"] as? String,
                    self.isGreaterOrEqualRevCount(rev, lockedRev)
                    else { return false }
                return true
            }
        } ?? false
    }
    
    /// Add locked orders.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to add to.
    ///   - station: The `Station` that locks the given `Order`s.
    ///   - employee: The `Employee` that locks the given `Order`s.
    ///   - orders: The `Order`s.
    /// - Returns: `true` if anything got updated.
    func addLockedOrders(_ storeID: String, by station: (String, String), by employee: (String, String), orders: [String: String]) -> Bool {
        guard storeID.isNotEmpty, station.0.isNotEmpty, employee.0.isNotEmpty, orders.isNotEmpty else { return false }
        return modifyLockedOrder(storeID) { pro -> [String : Any]? in
            var newPro = pro
            for order in orders {
                newPro[order.key] = [
                    "station"                  : station.0,
                    "station_name"             : station.1,
                    "current_employee"         : employee.0,
                    "current_employee_name"    : employee.1,
                    "status"                   : "locked",
                    "rev"                      : order.value
                ]
            }
            return newPro
        }
    }
    
    /// Remove orders locked by given station.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to remove for.
    ///   - stationID: The `Station` to remove for.
    /// - Returns: `true` if anything got updated.
    func removeAllLockedOrders(_ storeID: String, of stationID: String? = nil) -> Bool {
        if let stationID = stationID, stationID.isNotEmpty {
            return modifyLockedOrder(storeID) { pro -> [String : Any]? in
                if pro.any({ (key, value) in
                    guard let lockedOrder = value as? [String: Any],
                        let lockedStationID = lockedOrder["station"] as? String,
                        lockedStationID == stationID
                        else { return false }
                    return true
                }) {
                    return pro.filter { (orderID, value) -> Bool in
                        guard let lockedOrder = value as? [String: Any],
                            let lockedStationID = lockedOrder["station"] as? String,
                            lockedStationID != stationID
                            else { return false }
                        return true
                    }.dictionary()
                } else { return nil }
            }
        } else {
            return modifyLockedOrder(storeID) { pro -> [String : Any]? in
                if pro.isEmpty { return nil }
                else { return [:] }
            }
        }
    }
    
    /// Remove locked `Order`s by comparing the removing rev with the being locked rev.
    /// if removing rev is greater or equal being locked rev, the locking shall be removed.
    /// Otherwise, the locked order is changed to waiting-unlocked status.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to update for.
    ///   - stationID: The `Station` to remove for.
    ///   - orders: The list of `Order` to remove locked.
    /// - Returns: `true` if anything got updated.
    func removeLockedOrders(_ storeID: String, of stationID: String, orders: [String: String]) -> Bool {
        guard orders.isNotEmpty else { return false }
        return modifyLockedOrder(storeID) { pro -> [String : Any]? in
            var newPro = pro
            for (orderID, orderRev) in orders {
                guard let lockedOrder = pro[orderID] as? [String: Any],
                    let lockedStationID = lockedOrder["station"] as? String,
                    stationID == lockedStationID else { continue }
                let currentRev = self.loadOrder(rev: orderID)
                if self.isGreaterOrEqualRevCount(currentRev, orderRev) {
                    newPro.removeValue(forKey: orderID)
                } else {
                    var newLockedOrder = lockedOrder
                    newLockedOrder["status"] = "waiting-unlocked"
                    newLockedOrder["rev"] = orderRev
                    newPro[orderID] = newLockedOrder
                }
            }
            return newPro
        }
    }
    
    /// Checking the current revision and make sure waiting-unlocked got removed.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to update for.
    ///   - orderID: The `Order` to update for.
    /// - Returns: `true` if anything got updated.
    func updateLockedOrders(_ storeID: String, for orderID: String) -> Bool {
        guard orderID.isNotEmpty else { return false }
        return modifyLockedOrder(storeID) { pro -> [String:Any]? in
            guard let lockedOrder = pro[orderID] as? [String:Any],
                let lockedRev = lockedOrder["rev"] as? String,
                lockedRev.isNotEmpty else { return nil }
            let currentRev = self.loadOrder(rev: orderID)
            guard self.isGreaterOrEqualRevCount(currentRev, lockedRev) else { return nil }
            var newPro = pro
            if let lockedStatus = lockedOrder["status"] as? String, lockedStatus == "waiting-unlocked" {
                newPro.removeValue(forKey: orderID)
                d("REMOVE LOCKED ORDER \(orderID)")
            } else {
                var newLockedOrder = lockedOrder
                newLockedOrder["rev"] = currentRev
                newPro[orderID] = newLockedOrder
                d("UPDATED LOCKED ORDER \(orderID) to \(currentRev)")
            }
            return newPro
        }
    }
    
    /// Update all locked `Order`s for a given `Station`.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to update for.
    ///   - stationID: The `Station` to update for.
    /// - Returns: `true` if anything got updated.
    func updateAllLockedOrders(_ storeID: String, for stationID: String) -> Bool {
        guard stationID.isNotEmpty else { return false }
        return modifyLockedOrder(storeID) { pro -> [String:Any]? in
            var newPro = pro
            var updated = false
            for (orderID, value) in pro {
                guard let lockedOrder = value as? [String:Any],
                    let lockedStation = lockedOrder["station"] as? String,
                    lockedStation == stationID,
                    let lockedRev = lockedOrder["rev"] as? String,
                    lockedRev.isNotEmpty else { continue }
                let currentRev = self.loadOrder(rev: orderID)
                guard self.isGreaterOrEqualRevCount(currentRev, lockedRev) else { continue }
                
                if let lockedStatus = lockedOrder["status"] as? String, lockedStatus == "waiting-unlocked" {
                    newPro.removeValue(forKey: orderID)
                    d("REMOVE LOCKED ORDER \(orderID)")
                } else {
                    var newLockedOrder = lockedOrder
                    newLockedOrder["rev"] = currentRev
                    newPro[orderID] = newLockedOrder
                    d("UPDATED LOCKED ORDER \(orderID) to \(currentRev)")
                }
                updated = true
            }
            return updated ? newPro : nil
        }
    }

    
    /// Query the locked orders and map the properties to expected result.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - map: The map to convert LockedOrders' properties to expected type.
    /// - Returns: The expected type.
    fileprivate func mapLockedOrder<T>(_ storeID: String, map: @escaping ([String: Any]) -> T?) -> T? {
        guard storeID.isNotEmpty else { return nil }
        let prop = database?.document(withID: "\(lockedOrdersDocPrefix)\(storeID)")?.userProperties ?? [:]
        return map(prop)
    }
    
    /// Modify locked orders with custom modify method.
    ///
    /// - Returns: `true` if locked orders got modified.
    fileprivate func modifyLockedOrder(_ storeID: String, caller: String = #function, modify: @escaping ([String:Any]) -> [String:Any]?) -> Bool {
        guard storeID.isNotEmpty else { return false }
        guard let doc = database?.document(withID: "\(lockedOrdersDocPrefix)\(storeID)") else {
            return false
        }
        d("[\(caller)] UPDATING LOCKEDORDERS \(doc.currentRevisionID ?? "")")
        do {
            try doc.update { rev -> Bool in
                guard let pro = modify(rev.userProperties ?? [:]) else { return false }
                rev.userProperties = pro
                return true
            }
            d("[\(caller)] UPDATED LOCKEDORDERS \(doc.currentRevisionID ?? "")")
            // Log the content
            if let pro = doc.currentRevision?.properties {
                d(pro.toJsonString())
            }
        }
        catch { e(error) }
        
        return true
    }
    
    /// Compare 2 revisions.
    ///
    /// - Parameters:
    ///   - lhs: Revision ID.
    ///   - rhs: Revision ID.
    /// - Returns: The locked detail.
    fileprivate func isGreaterOrEqualRevCount(_ lhs: String, _ rhs: String) -> Bool {
        let lhsCounter = Int(lhs.components(separatedBy: "-").first ?? "0") ?? 0
        let rhsCounter = Int(rhs.components(separatedBy: "-").first ?? "0") ?? 0
        return lhsCounter >= rhsCounter
    }
}
