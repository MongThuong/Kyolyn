//
//  RestClient+Customer.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension RestClient {
    
    /// Search for customers matching the given customer.
    ///
    /// - Parameters:
    ///   - by: the template customer to search for.
    ///   - limit: the limit returned rows.
    /// - Returns: Single of the loading result.
    func load(customers query: (String, String, String, String), limit: UInt) -> Single<[Customer]> {
        guard let storeID = store?.id else {
            return Single.just([])
        }
        let (name, phone, email, address) = query
        let params: [String: Any] = [
            "customerid": "",
            "customername": name,
            "customerphone": phone,
            "customeremail": email,
            "customeraddress": address,
            "limit": limit
        ]
        return load(multiModel: "store/\(storeID)/customer/find", params: params)
    }

    /// Load customers from Main for current Store
    ///
    /// - Parameters:
    ///   - page: the page to load for.
    ///   - pageSize: the page limit to load for
    /// - Returns: Single of the loading result.
    func loadCustomers(page: UInt, pageSize: UInt) -> Single<QueryResult<Customer>> {
        guard let storeID = store?.id else {
            return Single.just(QueryResult())
        }
        let params: [String: Any] = [ "page": page, "pagecount": pageSize ]
        return query(model: "store/\(storeID)/customer", params: params)
    }
}
