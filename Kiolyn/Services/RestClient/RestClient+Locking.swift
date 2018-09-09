//
//  RestClient+Locking.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

extension RestClient {
    
    /// Ask Main to lock the given Order' id(s).
    ///
    /// - Parameter orders: the Order' id(s) to be locked.
    /// - Returns: Single of the Order(s) that were locked.
    func lock(orders: [String]) -> Single<[Order]> {
        guard let mainURL = self.mainURL?.absoluteString, let storeID = store?.id, let stationID = station?.id else {
            return Single.just([])
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/store/\(storeID)/order/lock"
            let data: [String: Any] = ["station_id": stationID, "orders": orders]
            Alamofire.request(endpoint, method: .post, parameters: data, encoding: JSONEncoding.default)
                .log()
                .responseArray(queue: self.queue) { (res: DataResponse<[Order]>) in
                    if let error = res.error {
                        e(error)
                        if let data = res.data, let strRes = String(data: data, encoding: .utf8) {
                            d("RES - \(strRes)")
                        }
                        return single(.error(LockingOrderError.alreadyLocked))
                    }
                    single(.success(res.value ?? []))
            }
            return Disposables.create()
        }
    }
    
    /// Unlock all orders that are kept by the current station
    ///
    /// - Returns: Single of the unlocking result.
    func unlockAllOrders() -> Single<Bool> {
        guard let mainURL = self.mainURL?.absoluteString, let storeID = store?.id, let stationID = station?.id else {
            return Single.just(false)
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/store/\(storeID)/order/unlock-all"
            let data: [String: Any] = ["station_id": stationID]
            Alamofire.request(endpoint, method: .post, parameters: data, encoding: JSONEncoding.default)
                .log()
                .responseJSON(queue: self.queue) { (res: DataResponse<Any>) in
                    if let error = res.error {
                        e(error)
                    }
                    single(.success((res.value as? Bool) ?? false))
            }
            return Disposables.create()
        }
    }
    
    /// Load the current locked orders from Main.
    ///
    /// - Returns: Single of the result.
    func loadLockedOrders() -> Single<[String: String]> {
        guard let mainURL = self.mainURL?.absoluteString, let storeID = store?.id else {
            return Single.just([:])
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/store/\(storeID)/order/locked"
            Alamofire.request(endpoint)
                .log()
                .responseJSON(queue: self.queue) { (res: DataResponse<Any>) in
                    if let error = res.error {
                        e(error)
                    }
                    single(.success((res.value as? [String: String]) ?? [:]))
            }
            return Disposables.create()
        }
    }
}
