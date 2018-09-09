//
//  NavigationManager.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FontAwesomeKit

/// Contain ALL the main area views
///
/// - tables: Tables selection view
/// - ordering: Ordering view.
/// - customers: Customers view.
/// - transactions: Transactions view.
/// - totalReport: By payment type summary report view.
/// - byPaymentTypeDetailReport: By payment type detail report view.
/// - byServerReport: By server summary/detail report view.
/// - byShiftAndDayReport: By shift and day report view.
enum MainContentViewType: String  {
    case tablesLayout = "TablesLayout"
    case ordering = "Ordering"
    case customers = "Customers"
    case transactions = "Transactions"
    case totalReport = "TotalReport"
    case transactionReport = "TransactionReport"
    case byServerReport = "ByServerReport"
    case byShiftAndDayReport = "ByShiftAndDayReport"
}

/// Sub view (interaction area) of ordering view.
///
/// - menu: The menu.
/// - orders: The list of orders.
/// - bills: The list of bills.
enum OrderingInteractionViewType {
    case empty
    case menu
    case orders
    case bills
}

/// Handle the navigation.
class NavigationManager {
    let disposeBag = DisposeBag()
    /// For publishing to request for changing the main content view.
    let mainView = BehaviorRelay<MainContentViewType>(value: .tablesLayout)
    /// For publishing to request for changing of ordering interaction view.
    let orderingInteractionView = BehaviorRelay<OrderingInteractionViewType>(value: .empty)
    
    init() {
        // Change main view to ordering, then change to requested ordering interaction view
        orderingInteractionView
            .filter { $0 != .empty }
            .subscribe(onNext: { type in
                // Change to ordering if need to
                if self.mainView.value != .ordering {
                    self.mainView.accept(.ordering)
                }
            })
            .disposed(by: disposeBag)
    }
}


