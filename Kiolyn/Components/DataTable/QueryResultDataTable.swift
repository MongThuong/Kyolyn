//
//  QueryResultDataTable.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Use `QueryResult` as result of data loading.
class CommonDataTableViewModel<T: Mappable> : DataTableViewModel<QueryResult<T>, T> { }

