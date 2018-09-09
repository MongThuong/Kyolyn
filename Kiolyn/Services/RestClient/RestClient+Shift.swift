//
//  RestClient+Shift.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension RestClient {
    
    /// Load the active shift from main.
    ///
    /// - Returns: Single of the active shift.
    func loadActiveShift() -> Single<Shift?> {
        guard let storeID = store?.id else {
            return Single.just(nil)
        }
        return load(model: "store/\(storeID)/shift/active")
    }
    
    /// Increase a counter on Main.
    ///
    /// - Parameter counter: the counter to be increased.
    /// - Returns: Single of the active shift.
    func increaseActiveShift(counter: ShiftCounter) -> Single<Shift?> {
        guard let storeID = store?.id else {
            return Single.just(nil)
        }
        return post(model: "store/\(storeID)/shift/active/counter/\(counter.rawValue.lowercased())", data: [:])
    }
}
