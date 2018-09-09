//
//  SelectClockoutReasonDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For selecting clockout reason.
class SelectClockoutReasonDVM: SelectItemDVM<Reason> {
    /// The store to get the reason for.
    private let _store: Store
    
    /// This view model is called on Login screen where all the login information is not ready yet.
    /// Thus we need to set the `Store` manually
    ///
    /// - Parameter store: The `Store` to get reason for.
    init(forStore store: Store) {
        _store = store
        super.init(nil, withTitle: "Select Clockout Reason")
    }
    
    override func loadData() -> Single<[Reason]> {
        return SP.timecard.clockoutReasons(of: _store)
    }
}
