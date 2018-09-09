//
//  DataService+Generic.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension DataService {
    
    /// Load single object async
    ///
    /// - Parameter id: the object id to load for.
    /// - Returns: `Single` of the loading result.
    func load<T: BaseModel>(_ id: String) -> Single<T?> {
        guard id.isNotEmpty else { return Single.just(nil) }
        if isMain {
            return db.async {
                self.db.load(id)
            }
        } else {
            return restClient.load(id)
        }
    }
    
    /// Load multiple objects using their ids.
    ///
    /// - Parameter ids: the object ids to load for.
    /// - Returns: `Single` of the loading result
    func load<T: BaseModel>(multi ids: [String]) -> Single<[T]> {
        guard ids.isNotEmpty else { return Single.just([]) }
        if isMain {
            return db.async {
                let objs: [T?] = self.db.load(multi: ids)
                return objs
                    .filter { $0 != nil } // Remove the nil
                    .map { obj -> T in obj! } // Cast to T
            }
        } else {
            return restClient.load(multi: ids)
        }
    }
    
    /// Load all objects of given Type belong to the current Store.
    ///
    /// - Parameter storeID: the store to load for.
    /// - Returns: `Single` of the result.
    func loadAll<T:BaseModel>() -> Single<[T]> {
        if isMain {
            return db.async {
                self.db.load(all: self.store.id)
            }
        } else {
            return restClient.loadAll()
        }
    }
    
    /// Save a single object
    ///
    /// - Parameter obj: the obj to save.
    /// - Returns: `Single` of the saving result.
    func save<T: BaseModel>(_ obj: T) -> Single<T?> {
        if let order = obj as? Order {
            return save(order: order) as! Single<T?>
        }
        return save(all: [obj]).map { objs in objs.first as? T }
    }
    
    /// Save multiple objects.
    ///
    /// - Parameter obj: the obj to save.
    /// - Returns: `Single` of the saving result.
    func save(all objs: [BaseModel]) -> Single<[BaseModel]> {
        for obj in objs {
            obj.updatedAt = BaseModel.timestamp
            obj.updatedBy = id?.employee.id ?? ""
        }
        if isMain {
            return db.async {
                try self.db.save(all: objs)
                return objs
            }
        } else {
            return restClient.save(models: objs)
                .map { revisions in revisions.isEmpty ? [] : objs }
        }
    }
    
    /// Delete a single object
    ///
    /// - Parameter obj: the obj to save.
    /// - Returns: `Single` of the saving result.
    func delete<T: BaseModel>(_ obj: T) -> Single<T?> {
        if let order = obj as? Order {
            return delete(order: order).map { _ in obj }
        }
        
        obj.updatedAt = BaseModel.timestamp
        obj.updatedBy = id?.employee.id ?? ""
        if isMain {
            return db.async { () -> T in
                try self.db.delete(obj)
                return obj
            }
        } else {
            return restClient.delete(model: obj.id)
                .map { _ -> T? in obj }
        }
    }
}
