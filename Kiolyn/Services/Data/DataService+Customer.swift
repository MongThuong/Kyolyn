//
//  DataService+Customer.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension DataService {
    
    /// Load customers based on query data
    ///
    /// - Parameters:
    ///   - storeID: the store to load in
    ///   - query: the query parameters
    /// - Returns: `Single` of the customers loading result.
    func load(customers query: (String, String, String, String)) -> Single<[Customer]> {
        if self.isMain {
            return self.db.async {
                return self.db.load(customers: self.store.id, query: query, limit: 10)
            }
        } else {
            return restClient.load(customers: query, limit: 10)
        }
    }
    
    /// Load customers with pagination.
    ///
    /// - Parameters:
    ///   - page: the page to load for.
    ///   - pageSize: the page count to load for.
    /// - Returns: Single of the loading result.
    func loadCustomers(page: UInt, pageSize: UInt) -> Single<QueryResult<Customer>> {
        if self.isMain {
            return self.db.async {
                return self.db.load(customers: self.store.id, page: page, pageSize: pageSize)
            }
        } else {
            return restClient.loadCustomers(page: page, pageSize: pageSize)
        }
    }
}
