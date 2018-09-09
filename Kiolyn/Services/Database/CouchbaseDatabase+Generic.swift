//
//  CBDatabaseGeneric.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

/// Generic querying of Object.
extension CouchbaseDatabase {
    
    static var docTypePrefixes: [String: String] {
        return [
            Area.documentType: Area.documentIDPrefix,
            CCDevice.documentType: CCDevice.documentIDPrefix,
            Station.documentType: Station.documentIDPrefix,
            Customer.documentType: Customer.documentIDPrefix,
            Printer.documentType: Printer.documentIDPrefix,
            Order.documentType: Order.documentIDPrefix,
            Shift.documentType: Shift.documentIDPrefix,
            Transaction.documentType: Transaction.documentIDPrefix,
            TimeCard.documentType: TimeCard.documentIDPrefix,
        ]
    }

    func save(properties: [String: Any]) throws -> String {
        guard let id = properties["id"]  as? String, id.isNotEmpty else {
            throw DatabaseError.missingMeta(field: "id")
        }
        guard let type = properties["type"] as? String, databaseMutableObjectTypes.contains(type),
            let prefix = CouchbaseDatabase.docTypePrefixes[type] else {
            throw DatabaseError.missingMeta(field: "type")
        }
        guard let merchantid = properties["merchantid"]  as? String, merchantid.isNotEmpty else {
            throw DatabaseError.missingMeta(field: "merchantid")
        }
        if databasePushableObjectTypes.contains(type) {
            guard let channels = properties["channels"] as? [String], channels.isNotEmpty else {
                throw DatabaseError.missingMeta(field: "channels")
            }
        }
        return try save(document: "\(prefix)_\(id)", properties: properties)
    }
    
    func save(properties: [[String: Any]]) throws -> [String] {
        var revisions: [String] = []
        try runBatch {
            revisions = try properties.map { p in
                try self.save(properties: p)
            }
        }
        return revisions
    }
    
    func save(_ obj: BaseModel) throws {
        let objType = type(of: obj)
        d("Saving \(objType) \(obj)/\(obj.revision)")
        guard obj.id.isNotEmpty else {
            throw DatabaseError.missingMeta(field: "id")
        }
        guard obj.type.isNotEmpty else {
            throw DatabaseError.missingMeta(field: "type")
        }
        guard obj.merchantID.isNotEmpty else {
            throw DatabaseError.missingMeta(field: "merchantID")
        }
        if databasePushableObjectTypes.contains(obj.type) {
            guard obj.channels.isNotEmpty else {
                throw DatabaseError.missingMeta(field: "channels")
            }
        }
        _ = try save(document: "\(objType.documentIDPrefix)_\(obj.id)", properties: obj.toJSON())
    }
    
    private func save(document docID: String, properties: [String: Any]) throws -> String {
        if let doc = database[docID] {
            do {
                // Update the store locally
                try doc.update({ revision -> Bool in
                    // Update properties
                    revision.userProperties = properties
                    // Allow update
                    return true
                })
                return doc.currentRevisionID!
            } catch {
                e("Could not save document \(docID)\n\(error.localizedDescription)")
                throw DatabaseError.couldNotSaveDocument(error: error)
            }
        } else {
            e("Could not save document \(docID)")
            throw DatabaseError.couldNotGetNorCreateDocument(id: docID)
        }
    }

    func save(all objs: [BaseModel]) throws {
        try runBatch {
            for obj in objs {
                try self.save(obj)
            }
        }
    }

    func load<T: BaseModel>(_ id: String) -> T? {
        // normal loading goes here
        guard id.isNotEmpty else {
            return nil
        }
        // Get the doc and create the model accordingly
        if let doc = load(document: "\(T.documentIDPrefix)_\(id)"), let properties = doc.properties {
            return T(JSON: properties)
        }
        return nil
    }
    
    private func load(document id: String) -> CBLDocument? {
        guard id.isNotEmpty else { return nil }
        guard let doc = database.existingDocument(withID: id) else {
            d("[DB] Document not found \(id)")
            return nil
        }
        if Configuration.logLoadedDocument {
            v("[DB] Document loaded for \(id) \n\(doc.properties?.toJsonString() ?? "EMPTY")")
        }
        return doc
    }
    
    func load(properties docID: String) -> [String: Any]? {
        return load(document: docID)?.properties
    }
    
    func load<T:BaseModel>(all storeID: String) -> [T] {
        return load(all: storeID, byName: "")
    }
    
    func load<T:BaseModel>(all storeID: String, byName name: String) -> [T] {
        return loadProperties(all: storeID, for: T.self, byName: name)
            .map { properties in T(JSON: properties) }
            .filter { model in model != nil }
            .map { model -> T in model! }
    }
    
    func loadProperties(all storeID: String, for type: BaseModel.Type, byName name: String) -> [[String: Any]] {
        guard let map = type.allMapBlock, storeID.isNotEmpty else {
            return []
        }
        // Get/Create the all document view
        let view = database.viewNamed("all_\(type.documentType)")
        view.setMapBlock(map, version: CouchbaseDatabase.VERSION)
        
        let query = view.createQuery()
        query.keys = [ storeID ]
        query.mapOnly = true
        query.prefetch = true
        
        if name.isNotEmpty {
            query.postFilter = NSPredicate { (row, _) -> Bool in
                // make sure there is a returned row
                guard let row = row as? CBLQueryRow,
                    // ... with properties
                    let properties = row.documentProperties,
                    // ... and having a name
                    let n = properties["name"] as? String
                    else {
                        return false
                }
                return name == n
            }
        }
        return query.loadPropertiesList()
    }
    
    func load<T: BaseModel>(multi ids: [String]) -> [T?] {
        return ids.map { id -> T? in return self.load(id) }
    }
    
    func loadProperties(multi ids: [String], for type: BaseModel.Type) -> [[String: Any]?] {
        return ids.map { id in self.load(properties: "\(type.documentIDPrefix)_\(id)") }
    }
    
    func loadProperties(multi ids: [String]) -> [[String: Any]?] {
        return ids.map { id in self.load(properties: id) }
    }
    
    func delete(_ docID: String) throws {
        guard let doc = load(document: docID) else {
            d("Document not found for \(docID)")
            return
        }
        d("Deleting \(doc.documentID)/\(doc.currentRevisionID ?? "")")
        doc.expirationDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        do {
            try doc.delete()
        } catch {
            e(error)
            throw DatabaseError.couldNotDeleteDocument(error: error)
        }
        d("Deleted \(doc.documentID)/\(doc.currentRevisionID ?? "") (truly deleted after 1 day)")
    }

    func delete<T: BaseModel>(_ obj: T) throws {
        try delete(obj.documentID)
    }
    
    func delete<T: BaseModel>(multi objs: [T]) throws {
        for obj in objs {
            try delete(obj)
        }
    }

    func runBatch(_ block: @escaping () throws -> Void) throws {
        var lastError: Error?
        _ = database.inTransaction {
            do {
                try block()
                return true
            } catch {
                lastError = error
                return false
            }
        }
        // throw error if any
        if let error = lastError { throw error }
    }    
}
