//
//  DataService+Shift.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension DataService {
    /// Load current Store's active shift
    ///
    /// - Returns: `Single` of the active shift.
    func loadActiveShift() -> Single<Shift?> {
        if self.isMain {
            return self.db.async {
                let shift = self.db.load(activeShift: self.store.id)
                self.activeShift.accept(shift)
                return shift
            }
        } else {
            return restClient.loadActiveShift()
                .map { shift in
                    self.activeShift.accept(shift)
                    return shift
            }
        }
    }
    
    /// Real logic of the counter increasing.
    ///
    /// - Parameter counter: The counter var to increase.
    /// - Returns: The current active `Shift`.
    /// - Throws: Any DataServiceError.
    func increase(store storeID: String, counter: ShiftCounter) throws -> Shift? {
        guard let shift = self.db.load(activeShift: storeID) else {
            return nil
        }
        // Update counter active shift
        switch counter {
        case .orderNo:
            shift.orderNum += 1
        case .transNo:
            shift.transNum += 1
        }
        try self.db.save(shift)
        return shift
    }
    
    /// Increase counter inside active shift.
    ///
    /// - Parameters:
    ///   - counter: The counter var to increase.
    /// - Returns: The current active `Shift`.
    func increase(counter: ShiftCounter) -> Single<Shift?> {
        if self.isMain {
            return self.db.async {
                try self.increase(store: self.store.id, counter: counter)
            }
        } else {
            return restClient.increaseActiveShift(counter: counter)
        }
    }
    
    /// Check for the active shift status.
    ///
    /// - Returns: the active shift status.
    func checkActiveShiftStatus() -> Single<ActiveShiftStatus> {
        guard isMain else {
            return Single.just(.notSupported)
        }
        
        let storeID = store.id
        
        return self.db.async {
            guard let activeShift = self.db.load(activeShift: storeID) else {
                return .noActiveShift
            }
            guard self.db.count(unsettledTransactions: storeID, forShift: activeShift.id) == 0 else {
                return .hasUnsettledTransactions
            }
            guard self.db.count(openingOrders: storeID, forShift: activeShift.id) == 0 else {
                return .hasOpeningTables
            }
            return .canClose
        }
    }
    
    /// Open a new shift.
    ///
    /// - Returns: the single of new shift
    func openNewShift() -> Single<Shift?> {
        guard isMain, let employee = id?.employee else {
            return Single.just(nil)
        }
        let storeID = store.id

        return self.db.async {
            // Count the shift of the day
            let shiftIndex = self.db.count(shifts: storeID, in: Date())
            // Create new shift with the next index
            let newShift = Shift(inStore: self.store, byEmployee: employee, index: shiftIndex + 1)
            try self.db.save(newShift)
            // Set the new shift
            self.activeShift.accept(newShift)
            return newShift
        }
    }
    
    /// Close the current active shift.
    ///
    /// - Returns: `Single` of the closing shift result.
    func closeActiveShift() -> Single<Shift?> {
        guard isMain, let employee = id?.employee else {
            return Single.just(nil)
        }
        let ts = SP.timecard
        let storeID = store.id
        
        return self.db.async {
            guard let activeShift = self.db.load(activeShift: storeID) else {
                return nil
            }
            // Close  active shift
            activeShift.closedAt = BaseModel.timestamp;
            activeShift.closedBy = employee.id;
            activeShift.closedByName = employee.name;

            var updatedModels: [BaseModel] = [activeShift]
            // Clockout all timecard and add to updated models
            let updatedTimecards = ts.clockout(all: storeID)
            updatedModels.append(contentsOf: updatedTimecards.map { $0 as BaseModel })
            
            // Check for opening orders
            var orders = self.db.load(openingOrders: storeID, forShift: activeShift.id, inArea: nil, withFilter: "")

            // Not moving anything, just close
            if orders.isEmpty {
                // Save the models in one single shot
                try self.db.save(all: updatedModels)
                // Clear the current shift
                self.activeShift.accept(nil)
                return nil
            } else {
                // Count the shift of the day
                let shiftIndex = self.db.count(shifts: storeID, in: Date())
                // Create new shift with the next index
                // Create new shift with the next index
                let newShift = Shift(inStore: self.store, byEmployee: employee, index: shiftIndex + 1)
                updatedModels.append(newShift)
                // Sort by order no
                orders.sort { (lhs, rhs) -> Bool in
                    return lhs.orderNo > rhs.orderNo
                }
                // Update order no
                for order in orders {
                    newShift.orderNum += 1
                    order.orderNo = newShift.orderNum
                    order.shift = newShift.index;
                    order.shiftID = newShift.id;
                }
                updatedModels.append(contentsOf: orders as [BaseModel])
                // Save the models in one single shot
                try self.db.save(all: updatedModels)
                // Update new shift
                self.activeShift.accept(newShift)
                return newShift
            }
        }
    }
}

/// The counter of shift.
enum ShiftCounter: String {
    case orderNo = "orderno"
    case transNo = "transno"
}

/// Active shift status
///
/// - canClose: Shift can be closed.
/// - hasUnsettledTransactions: Shift has unsettled transactions.
/// - hasOpeningTables: Shift has opening tables.
enum ActiveShiftStatus {
    case notSupported
    case noActiveShift
    case canClose
    case hasUnsettledTransactions
    case hasOpeningTables
}
