//
//  RestClient+Document.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/3/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

extension RestClient {
    /// Load object remotely from Main.
    ///
    /// - Parameter id: id of the object
    /// - Returns: Single of the result
    func load<T: BaseModel>(_ id: String) -> Single<T?> {
        return load(model: "doc/\(T.documentIDPrefix)_\(id)")
    }
    
    /// Load all object of given type which belongs to current Store.
    ///
    /// - Returns: Single of the result.
    func loadAll<T: BaseModel>() -> Single<[T]> {
        guard let storeID = store?.id, let className = NSStringFromClass(T.self).components(separatedBy: ".").last else {
            return Single.just([])
        }
        return load(multiModel: "store/\(storeID)/all/\(className)")
    }
    
    /// Load all objects with given ids
    ///
    /// - Parameter ids: the object ids.
    /// - Returns: Single of the result.
    func load<T: BaseModel>(multi ids: [String]) -> Single<[T]> {
        let docIDs = ids.map { id in "\(T.documentIDPrefix)_\(id)" }
        return load(multiModel: "docs?ids=\(docIDs.joined(separator: ","))")
    }
    
    /// Save a list of objects.
    ///
    /// - Parameter models: the liswt of objects to save.
    /// - Returns: Single of the result.
    func save(models: [BaseModel]) -> Single<[String]> {
        guard let mainURL = self.mainURL?.absoluteString else {
            return Single.just([])
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/docs"
            let data = models.map { m in m.toJSON() }            
            Alamofire.request(endpoint, method: .post, parameters: data.asParameters, encoding: ArrayEncoding())
                .log()
                .responseJSON(queue: self.queue) { (res: DataResponse<Any>) in
                    if let error = res.error {
                        e(error)
                    }
                    guard let revisions = res.value as? [String],
                        revisions.count == models.count else {
                        return single(.success([]))
                    }
                    single(.success(revisions))
            }
            return Disposables.create()
        }
    }
}
