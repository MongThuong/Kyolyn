//
//  RestClient+Menu.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension RestClient {
    
    /// Load item by its barcode.
    ///
    /// - Parameter barcode: the barcode used for loading.
    /// - Returns: Single of the loading result.
    func loadItem(barcode: String) -> Single<Item?> {
        guard let storeID = store?.id else {
            return Single.just(nil)
        }
        return load(model: "store/\(storeID)/item/barcode/\(barcode)")
    }
    
    /// Load all items belong to given category.
    ///
    /// - Parameter categoryID: the category to load for.
    /// - Returns: Single of the loading result.
    func load(items categoryID: String) -> Single<[Item]> {
        guard let storeID = store?.id else {
            return Single.just([])
        }
        return load(multiModel: "store/\(storeID)/category/\(categoryID)/items")
    }
    
    /// Load all the modifiers belong to a given item.
    ///
    /// - Parameter itemID: the item to load for.
    /// - Returns: Single of the loading result.
    func load(modifiers itemID: String) -> Single<[Modifier]> {
        guard let storeID = store?.id else {
            return Single.just([])
        }
        return load(multiModel: "store/\(storeID)/item/\(itemID)/modifiers")
    }
    
    /// Load all the global modifiers belong to current store.
    ///
    /// - Returns: Single of the loading result.
    func loadGlobalModifiers() -> Single<[Modifier]> {
        guard let storeID = store?.id else {
            return Single.just([])
        }
        return load(multiModel: "store/\(storeID)/modifier/global")
    }
}
