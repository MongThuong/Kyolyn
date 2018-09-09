//
//  CouchbaseDatabase+Station.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/21/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension CouchbaseDatabase {
    var stationByMacView: CBLView {
        let view = database.viewNamed("station_by_mac")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Station.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let macAddress = doc["mac_address"] as? String, macAddress.isNotEmpty else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, macAddress.lowercased()], nil)
        }, version: CouchbaseDatabase.VERSION)
        return view
    }

    func load(station storeID: String, byMacAddress mac: String) -> Station? {
        guard let properties = loadStation(properties: storeID, byMacAddress: mac) else {
            return nil
        }
        return Station(JSON: properties)
    }
    
    func loadStation(properties storeID: String, byMacAddress mac: String) -> [String: Any]? {
        guard storeID.isNotEmpty, mac.isNotEmpty else {
            return nil
        }
        
        let query = stationByMacView.createQuery()
        query.mapOnly = true
        query.prefetch = true
        
        if mac == Station.passthroughMac {
            query.startKey = [storeID]
            query.endKey = [storeID, [:]]
            query.postFilter = NSPredicate { (row, _) -> Bool in
                guard let row = row as? CBLQueryRow,
                    let properties = row.documentProperties,
                    let isMain = properties["main"] as? Bool
                    else { return false }
                return isMain
            }
        } else {
            query.keys = [[storeID, mac.lowercased()]]
        }
        return query.loadProperties()
    }
}
