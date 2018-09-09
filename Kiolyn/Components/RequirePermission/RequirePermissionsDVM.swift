//
//  RequirePermissionsDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/18/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RequirePermissionsDVM: DialogViewModel<Employee> {    
    let verify = PublishSubject<String>()
    let error = BehaviorRelay<String>(value: "")
    
    /// For editing an order.
    ///
    /// - Parameter store: The `Order` to edit.
    init(_ permission: String) {
        super.init()
        verify
            .flatMap { passkey in
                SP.authService
                    .verifyAsync(passkey: passkey, havingPermission: permission)
                    .catchError { error -> Single<Employee?> in
                        self.error.accept(error.localizedDescription)
                        return Single.just(nil)
                    }
            }
            .filterNil()
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}
