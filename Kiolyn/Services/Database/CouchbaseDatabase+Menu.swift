//
//  CouchbaseDatabase+Menu.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - Menu (Categories/Items/Modifiers)
extension CouchbaseDatabase {
    
    var itemByCategoryView: CBLView {
        let view = database.viewNamed("item_by_category")
        view.setMapBlock(
            { (doc, emit) in
                // Make sure good inputs
                guard doc["deleted"] == nil,
                    let type = doc["type"] as? String, type == Item.documentType,
                    let id = doc["id"] as? String, id.isNotEmpty,
                    let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                    // having a category
                    let catID = doc["category"] as? String, catID.isNotEmpty,
                    // not hidden
                    (doc["hidden"] as? Bool ?? false) == false,
                    // having a good name
                    let name = doc["name"] as? String, name.isNotEmpty else {
                        return
                }
                // User storeid (new Store) or merchantid (old Store)
                let storeID = (doc["storeid"] as? String) ?? merchantID
                emit([storeID, catID], nil)
        }, version: CouchbaseDatabase.VERSION)
        return view
    }
    
    func load(items storeID: String, forCategory category: String) -> [Item] {
        return self.loadProperties(items: storeID, forCategory: category)
            .map { properties in Item(JSON: properties)! }
    }
    
    func loadProperties(items storeID: String, forCategory category: String) -> [[String: Any]] {
        guard storeID.isNotEmpty, category.isNotEmpty else {
            return []
        }
        let query = itemByCategoryView.createQuery()
        query.keys = [ [storeID, category] ]
        query.mapOnly = true
        query.prefetch = true
        return query.loadPropertiesList()
    }
    
    func load(modifiers itemID: String) -> [Modifier] {
        // Load the item first
        guard let item: Item = load(itemID) else {
            return []
        }
        return item.modifiers
            .map { ref -> Modifier? in
                guard let modifier: Modifier = self.load(ref.id) else {
                    return nil
                }
                modifier.required = ref.required
                modifier.sameline = ref.sameline
                return modifier
            }
            .filter { $0 != nil }
            .map { $0! }
            .sorted(by: { (lhs, rhs) -> Bool in
                return "\(lhs.required ? 0 : 1)\(lhs.name)" < "\(rhs.required ? 0 : 1)\(rhs.name)"
            })
    }
    
    func loadProperties(modifiers itemID: String) -> [[String: Any]] {
        return load(modifiers: itemID).map { modifier in modifier.toJSON() }
    }
    
    func load(globalModifiers storeID: String) -> [Modifier] {
        return loadProperties(globalModifiers: storeID)
            .map { properties in Modifier(JSON: properties)! }
    }
    
    func loadProperties(globalModifiers storeID: String) -> [[String: Any]] {
        guard storeID.isNotEmpty else {
            return []
        }
        
        let view = database.viewNamed("all_\(Modifier.documentType)")
        view.setMapBlock(Modifier.allMapBlock!, version: CouchbaseDatabase.VERSION)

        let query = view.createQuery()
        query.keys = [storeID]
        query.mapOnly = true
        query.prefetch = true
        query.postFilter = NSPredicate { (row, _) -> Bool in
            // make sure there is a returned row
            guard let row = row as? CBLQueryRow,
                // ... with properties
                let properties = row.documentProperties,
                // ... and is global
                let global = properties["global"] as? Bool,
                // ... and having options
                let options = properties["options"] as? [[String: Any]]
                else {
                    return false
            }
            return global && options.isNotEmpty

        }
        return query.loadPropertiesList()
    }
}
