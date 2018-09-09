//
//  SelectAndEditReasonDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/10/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Select and edit `Reason`.
class SelectAndEditReasonDVM: DialogViewModel<String> {
    var reasons: [Reason]!
    let reason = BehaviorRelay<String>(value: "")
    
    init(_ reasons: [Reason]) {
        self.reasons = reasons
        super.init()
        dialogTitle.accept("Select Reason")
        
        reason
            .asDriver()
            .map { $0.isNotEmpty }
            .drive(canSave)
            .disposed(by: disposeBag)
        save
            .map { self.reason.value }
            .filterEmpty()
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}
