//
//  Category.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent a `Store` in system, this `Store` is not meant to be updated but getting from a Sync Session API call.
class Category: GridItemModel {
    /// Document type of this class
    override class var documentType: String { return "category" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "cat" }
    /// Return ALL category that
    /// 1. Has id
    /// 2. Has merchant id
    /// 3. Not yet deleted
    /// 4. Not hidden
    /// 5. Has a name
    /// 6. Has a category type
    override class var allMapBlock: CBLMapBlock? {
        return { (doc, emit) in
            // Make sure good inputs
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == documentType,
                let id = doc["id"] as? String, id.isNotEmpty,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                // not hidden
                (doc["hidden"] as? Bool ?? false) == false,
                // having a good name
                let name = doc["name"] as? String, name.isNotEmpty else {
                return
            }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            emit(storeID, nil)
        }
    }
    
    /// Type of Category, used for grouping of categories.
    fileprivate var categorytypes: [String] = []
    fileprivate var categorytype: String = ""
    
    /// Return `true` if this Category allow Open Item.
    var allowOpenItem = false
    /// The sorting order
    var order: Int = 0
    /// Return the list of printers (Id only - no detail info) assigned to this category.
    var printers: [BaseModel] = []
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        categorytypes <- map["category_types"]
        categorytype <- map["category_type"]
        allowOpenItem <- map["open_item"]
        order <- map["order"]
        printers <- map["printers"]
    }
}

extension Category {
    /// The list of category type in uppercassed, with backward compatible with category type
    var categoryTypes: [String] {
        if categorytypes.isNotEmpty {
            return categorytypes.map { $0.uppercased() }
        }
        if categorytype.isNotEmpty {
            return [type.uppercased()]
        }
        return []
    }

    /// Create and return an Open Item for this Category.
    ///
    /// - Returns: Open `Item` for this `Category`.
    var openItem: Item {
        let item = Item()
        item.category = id
        item.name = ""
        item.isOpenItem = true
        return item
    }
}


