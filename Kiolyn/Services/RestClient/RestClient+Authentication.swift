//
//  RestClient+Authentication.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension RestClient {
    
    /// Shortcut for loading store.
    ///
    /// - Parameter id: the store id.
    /// - Returns: Single of loading result.
    func load(store id: String) -> Single<Store?> {
        return load(id)
    }
    
    /// Load a station remotly
    ///
    /// - Parameters:
    ///   - storeID: the
    ///   - mac: the mac to load for
    /// - Returns: Single of the loading result
    func load(station storeID: String, byMacAddress mac: String) -> Single<Station?> {
        guard let stationID = mac.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Single.just(nil)
        }
        return load(model: "store/\(storeID)/station/\(stationID)")
    }
    
    /// Verify signin for combination of Store/Station/passkey
    ///
    /// - Parameters:
    ///   - store: the Store to verify against.
    ///   - station: the Station to verify against.
    ///   - passkey: the passkey to verify against.
    /// - Returns: Single of the result.
    func verify(signin store: Store, station: Station, passkey: String) -> Single<Identity?> {
        let data = ["station_id": station.id, "passkey": passkey]
        let request: Single<Identity?> = post(model: "store/\(store.id)/signin", data: data)
        return request.map { id in
            id?.store = store
            id?.station = station
            return id
        }
    }
    
    /// Verify if the given passkey have the required permisison.
    ///
    /// - Parameters:
    ///   - permission: the permisison to verify.
    ///   - passkey: the passkey to verify.
    /// - Returns: Single of the Employee that match the passkey and having the required permission.
    func verify(permission: String, for passkey: String) -> Single<Employee?> {
        guard let storeID = store?.id, let stationID = station?.id else {
            return Single.just(nil)
        }
        let data = ["station_id": stationID, "passkey": passkey, "permission": permission]
        return post(model: "store/\(storeID)/permission", data: data)
    }
}
