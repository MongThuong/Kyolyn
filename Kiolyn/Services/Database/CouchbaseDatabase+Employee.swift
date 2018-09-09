//
//  CouchbaseDatabase+Employee.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/21/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension CouchbaseDatabase {
    var employeeByPasskeyView: CBLView {
        let view = database.viewNamed("employee_by_passkey")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Employee.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    let passkey = doc["passkey"] as? String, passkey.isNotEmpty else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, passkey], nil)
        }, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    func load(employee storeID: String, byPasskey passkey: String) -> Employee? {
        guard storeID.isNotEmpty, passkey.isNotEmpty else {
            return nil
        }
        let query = employeeByPasskeyView.createQuery()
        query.keys = [ [storeID, passkey] ]
        query.mapOnly = true
        query.prefetch = true
        return query.loadModel()
    }
    
    func load(defaultDriver storeID: String) -> Employee? {
        guard let properties = loadProperties(defaultDriver: storeID) else {
            return nil
        }
        return Employee(JSON: properties)
    }
    
    func loadProperties(defaultDriver storeID: String) -> [String: Any]? {
        guard storeID.isNotEmpty else {
            return nil
        }
        let query = employeeByPasskeyView.createQuery()
        query.startKey = [storeID]
        query.endKey = [storeID, [:]]
        query.mapOnly = true
        query.prefetch = true
        query.postFilter = NSPredicate { (row, _) -> Bool in
            guard let row = row as? CBLQueryRow,
                let properties = row.documentProperties,
                let isDriver = properties["delivery_driver"] as? Bool
                else { return false }
            return isDriver
        }
        query.limit = 1
        return query.loadProperties()
    }
    
    func load(drivers storeID: String) -> [Employee] {
        return loadProperties(drivers: storeID)
            .map { properties in Employee(JSON: properties)! }
    }
    
    func loadProperties(drivers storeID: String) -> [[String: Any]] {
        guard storeID.isNotEmpty else {
            return []
        }
        let query = employeeByPasskeyView.createQuery()
        query.startKey = [storeID]
        query.endKey = [storeID, [:]]
        query.mapOnly = true
        query.prefetch = true
        query.postFilter = NSPredicate { (row, _) -> Bool in
            guard let row = row as? CBLQueryRow,
                let properties = row.documentProperties,
                let isDriver = properties["delivery_driver"] as? Bool
                else { return false }
            return isDriver
        }
        return query.loadPropertiesList()
    }
}
