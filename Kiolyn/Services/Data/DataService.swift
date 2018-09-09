//
//  ShiftServic.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/3/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias LockedOrders = [String: String]

extension Dictionary where Key == String, Value == String {
    func isLocked(_ order: Order) -> Bool {
        guard let lockingStationID = self[order.id], let stationID = SP.authService.station?.id else {
            return false
        }
        return lockingStationID != stationID
    }
    
    func isNotLocked(_ order: Order) -> Bool {
        return !isLocked(order)
    }
}

class DataService {
    let disposeBag = DisposeBag()
    
    /// Contain the list of orders locked by remote station
    let lockedOrders = BehaviorRelay<LockedOrders>(value: [:])
    
    /// Publish to this to raise remote order changed.
    let remoteOrderChanged = PublishSubject<[String]>()
    let localOrderChanged = PublishSubject<[String]>()
    
    /// Return the current active shift.
    let activeShift = BehaviorRelay<Shift?>(value: nil)
    
    /// Return the current identity
    var id: Identity? { return SP.authService.currentIdentity.value }
    
    /// True if the current station is Main, false otherwise.
    var isMain: Bool { return id?.station.main ?? false }
    
    /// The current store that data service is working with
    var store: Store { return id!.store }
    
    /// Return the database instance
    var db: Database {
//        guard isMain else {
//            fatalError("SUB should not access database directly")
//        }
        return SP.database
    }
    
    /// Return the rest client to access data from main
    var restClient: RestClient {
        return SP.restClient
    }
    
    init() {
        // Unlock all orders upon signing-in/signing-out.
        SP.authService.currentIdentity
            .asObservable()
            .flatMap { _ in self.unlockAllOrders() }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    /// Load items that belongs to a category.
    ///
    /// - Parameters:
    ///   - categoryID: the category to load for.
    /// - Returns: `Single` of the loading result.
    func load(items categoryID: String) -> Single<[Item]> {
        if self.isMain {
            return self.db.async {
                self.db.load(items: self.store.id, forCategory: categoryID)
            }
        } else {
            return restClient.load(items: categoryID)
        }
    }
    
    /// Load modifiers for a given item inside the current store
    ///
    /// - Parameter itemID: the item's id to load for.
    /// - Returns: `Single` of the modifiers.
    func load(modifiers itemID: String) -> Single<[Modifier]> {
        if self.isMain {
            return self.db.async {
                self.db.load(modifiers: itemID)
            }
        } else {
            return restClient.load(modifiers: itemID)
        }
    }
    
    /// Load global modifiers for a given store.
    ///
    /// - Parameter storeID: the store to load for.
    /// - Returns: `Single` of the modifiers.
    func loadGlobalModifiers() -> Single<[Modifier]> {
        if self.isMain {
            return self.db.async {
                self.db.load(globalModifiers: self.store.id)
            }
        } else {
            return restClient.loadGlobalModifiers()
        }
    }
}

/// Error relating to Remote/Local data activities.
enum DataServiceError: LocalizedError {
    case stationIsNotMain
    case noActiveShift
    case invalidIdentity
    case databaseError(error: Error)
    case unknownError    
}
