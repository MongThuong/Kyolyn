//
//  CBLQuery+Utils.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/14/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - Extension for convenience usage of `CBLQuery`.
extension CBLQuery {
    
    /// Error free single line querying.
    ///
    /// - Returns: the first returned object in dictionary format.
    func loadDict() -> [String: Any]? {
        do {
            return try self.run().nextRow()?.value as? [String: Any]
        } catch {
            e("Could not run query \(self.view?.name ?? ""): \(error)")
            return nil
        }
    }
    
    /// Error free single line querying.
    ///
    /// - Returns: the returned value or default if any error occured.
    func loadInt() -> Int {
        do {
            return try (self.run().nextRow()?.value as? Int) ?? 0
        } catch {
            e("Could not run query \(self.view?.name ?? ""): \(error)")
            return 0
        }
    }
    
    /// Error free querying.
    ///
    /// - Returns: the matched array of objects or empty if error.
    func loadModels<T: BaseModel>() -> [T] {
        do {
            let models: [T?] = try self.run().map { row in
                (row as? CBLQueryRow)?.loadModel()
            }
            return models.filter { $0 != nil }.map { m -> T in m! }
        } catch {
            e("Could not run query \(self.view?.name ?? ""): \(error)")
            return []
        }
    }
    
    /// Error free properties querying.
    ///
    /// - Returns: the list of properties.
    func loadPropertiesList() -> [[String: Any]] {
        do {
            let propertiesList = try self.run().map { row in
                (row as? CBLQueryRow)?.loadProperties()
            }
            return propertiesList.filter { $0 != nil }.map { $0! }
        } catch {
            e("Could not run query \(self.view?.name ?? ""): \(error)")
            return []
        }
    }
    
    /// Query a single model.
    ///
    /// - Returns: the single model.
    func loadModel<T: BaseModel>() -> T? {
        do {
            return try self.run().nextRow()?.loadModel()
        } catch {
            e("Could not run query \(self.view?.name ?? ""): \(error)")
            return nil
        }
    }

    /// Query the single result properties.
    ///
    /// - Returns: the single properties.
    func loadProperties() -> [String: Any]? {
        do {
            return try self.run().nextRow()?.loadProperties()
        } catch {
            e("Could not run query \(self.view?.name ?? ""): \(error)")
            return nil
        }
    }
    
    /// Error free querying.
    ///
    /// - Returns: multiple rows as key/value combination.
    func loadMulti() -> [(key: [Any], value: [String: Any])] {
        do {
            return try self.run().map { r in
                let row = r as! CBLQueryRow
                return (key: row.key as! [Any], value: row.value as! [String:Any])
            }
        } catch {
            e("Could not run query \(self.view?.name ?? ""): \(error)")
            return []
        }
    }
}

extension CBLQueryRow {
    /// Load a model from a query row.
    ///
    /// - Returns: the model if success.
    func loadModel<T: BaseModel>() -> T? {
        return document?.loadModel()
    }
    
    /// Load properties from a query row.
    ///
    /// - Returns: the properties if success.
    func loadProperties() -> [String: Any]? {
        return document?.properties
    }
}

extension CBLDocument {
    /// Load a model from a document.
    ///
    /// - Returns: the model if success.
    func loadModel<T: BaseModel>() -> T? {
        return T(JSON: properties ?? [:])
    }
}
