//
//  CustomersViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/16/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For handling Customers list related business.
class CustomersViewModel: CommonDataTableViewModel<Customer> {
    override func loadData() -> Single<QueryResult<Customer>> {
        return self.dataService.loadCustomers(page: page.value, pageSize: pageSize.value)
    }
}
