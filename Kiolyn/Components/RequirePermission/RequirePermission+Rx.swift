//
//  Authentication+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/10/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Check current employee permission to see whether he/she got the required permission.
/// Otherwise, open the passkey dialog for inputing a permission
///
/// - Parameter permission: the permission to verify.
/// - Returns: the `Observable` of the `Employee` with the authorized permisison.
func require(permission: String) -> Single<Employee?> {
    // Not login, not allow
    guard let employee = SP.authService.currentIdentity.value?.employee else {
        return Single.just(nil)
    }
    if employee.permissions.has(permission: permission) {
        return Single.just(employee)
    }
    return dmodal { RequirePermissionsDVM(permission) }
}
