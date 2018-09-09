//
//  CouchbaseLiteDatabase.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/3/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Couchbase Lite database
class CouchbaseDatabase: NSObject, Database {
    // MARK: Static
    
    static let VERSION = "1.4.808.1"
    
    /// Db specific dispatch queue
    private lazy var dispatchQueue: DispatchQueue = {
        return DispatchQueue(label: dbName, qos: .background)
    }()
    
    // The database name (must be passed in constructor)
    private let dbFile: String?
    private let dbName: String

    /// The CBL database instance.
    lazy var database: CBLDatabase = {
        // Get manager
        let manager = CBLManager()// CBLManager.sharedInstance().copy()
        manager.dispatchQueue = dispatchQueue
        d("[DB] Location \(manager.directory)")
        
        // Override with custom database name
        if let dbFile = self.dbFile {
            if manager.databaseExistsNamed(dbName) {
                try! manager.existingDatabaseNamed(dbName).delete()
            }
            try! manager.replaceDatabaseNamed(dbName, withDatabaseDir: dbFile)
        }
        // Create/Open the database
        let database = try! manager.databaseNamed(dbName)
        d("[DB] Total document \(database.documentCount)")
        
        // For filtering what to push to remote server.
        database.setFilterNamed("remotePushFilter") { (revision, filterParams) -> Bool in
            // Make sure there are type and type are in list of pushable types
            guard let type = revision.property(forKey: "type") as? String,
                databasePushableObjectTypes.contains(type) else {
                    return false
            }
            // Do not remotely sync the Order that is in NEW status
            if type == Order.documentType {
                guard let status = revision.property(forKey: "status") as? String,
                    status != OrderStatus.new.rawValue else {
                        return false
                }
            }
            let docStoreID = revision.property(forKey: "storeid") as? String
            let docMerchantID = revision.property(forKey: "merchantid") as? String
            // Make sure the document storeID matches with the requested storeID
            guard let storeID = docStoreID ?? docMerchantID,
                let paramStoreID = filterParams?["storeid"] as? String,
                storeID == paramStoreID else {
                    return false
            }
            // Pass all checking
            return true
        }
        
        // Register model factory (iOS only)
        if let factory = database.modelFactory {
            factory.registerClass(Store.self, forDocumentType: Store.documentType)
            factory.registerClass(Station.self, forDocumentType: Station.documentType)
            factory.registerClass(Employee.self, forDocumentType: Employee.documentType)
            factory.registerClass(Settings.self, forDocumentType: Settings.documentType)
            factory.registerClass(Category.self, forDocumentType: Category.documentType)
            factory.registerClass(Modifier.self, forDocumentType: Modifier.documentType)
            factory.registerClass(Area.self, forDocumentType: Area.documentType)
            factory.registerClass(Printer.self, forDocumentType: Printer.documentType)
            factory.registerClass(Item.self, forDocumentType: Item.documentType)
            factory.registerClass(Order.self, forDocumentType: Order.documentType)
            factory.registerClass(Shift.self, forDocumentType: Shift.documentType)
            factory.registerClass(Customer.self, forDocumentType: Customer.documentType)
            factory.registerClass(TimeCard.self, forDocumentType: TimeCard.documentType)
            factory.registerClass(Transaction.self, forDocumentType: Transaction.documentType)
            factory.registerClass(CCDevice.self, forDocumentType: CCDevice.documentType)
        }
        return database
    }()
    
    /// Return the document count
    var documentCount: UInt { return database.documentCount }
    
    init(file: String? = nil, name: String = "kiolyn") {
        self.dbFile = file
        self.dbName = name
        super.init()
    }
    
    deinit {
        do {
            try database.close()
        } catch (let e) {
            w("[DB] Error closing database \(e.localizedDescription)")
        }
    }
    
    /// Delete the current database.
    func deleteCurrentDatabase() {
        do {
            try database.delete()
        } catch (let e) {
            w("[DB] Error deleting database \(e.localizedDescription)")
        }
    }
    
    func async(_ task: @escaping () -> Void) {
        guard DispatchQueue.currentQueueLabel != dispatchQueue.label else {
            return task()
        }
        dispatchQueue.async(execute: task)
    }
    
    /// Simple reduce to return the total count of rows.
    var totalReduce: CBLReduceBlock {
        return { (keys, values, rereduce) in values.count }
    }
}
