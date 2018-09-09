//
//  BaseViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/12/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import FontAwesomeKit

/// Base View Model for alll view models.
class ViewModel {
    let disposeBag = DisposeBag()
    init() {
        guard Thread.isMainThread else {
            fatalError("ViewModel must be created on MainThread")
        }
    }
}

/// The Root View Model except the Login View Model.
class BaseViewModel: ViewModel {
    var id: Identity { return SP.authService.currentIdentity.value! }
    var store: Store { return id.store }
    var employee: Employee { return id.employee }
    var settings: Settings { return id.settings }
    var station: Station { return id.station }
    var defaultPrinter: Printer? { return id.defaultPrinter }
    var isMain: Bool { return station.main }
    var dataService: DataService {
        return SP.dataService
    }
    var orderManager: OrderManager {
        return SP.orderManager
    }
}
