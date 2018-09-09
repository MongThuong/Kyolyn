//
//  CouchbaseDatabase+Shift.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension CouchbaseDatabase {
    var openingShiftView: CBLView {
        let view = self.database.viewNamed("opening_shift")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Shift.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    // not yet closed
                    (doc["closed_at"] as? String) == nil ||
                        (doc["closed_at"] as! String).isEmpty else {
                            return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, id], nil)
        }, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    var shiftByDate: CBLView {
        let view = self.database.viewNamed("shift_by_date")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Shift.documentType,
                    let id = doc["id"] as? String, id.count > 6 ,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty
                    else { return }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, id[0...5]], nil)
        }, reduce: totalReduce, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    func load(activeShift storeID: String) -> Shift? {
        guard let properties = loadProperties(activeShift: storeID) else {
            return nil
        }
        return Shift(JSON: properties)
    }
    
    func loadProperties(activeShift storeID: String) -> [String: Any]? {
        guard storeID.isNotEmpty else {
            return nil
        }
        let query = openingShiftView.createQuery()
        query.startKey = [ storeID, [:] ]
        query.endKey = [ storeID ]
        query.descending = true
        query.limit = 1
        query.mapOnly = true
        query.prefetch = true
        return query.loadProperties()
    }
        
    func count(shifts storeID: String, in day: Date) -> UInt {
        guard storeID.isNotEmpty else {
            return 0
        }
        let query = shiftByDate.createQuery()
        query.keys = [ [ storeID, day.toString("YYMMdd") ] ]
        query.mapOnly = false
        query.prefetch = false
        do {
            let result = try query.run()
            guard result.count > 0, let count = result.row(at: 0).value as? Int else {
                return 0
            }
            return UInt(count)
        } catch {
            e("Could not count shifts: \(error)")
        }
        return 0
    }
}
