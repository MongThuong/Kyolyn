//
//  CCDevice+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    func ensureCCDevice() -> Observable<CCDevice> {
        let ds = SP.dataService
        let auth = SP.authService
        return self
            .flatMap { _ -> Single<CCDevice?> in
                guard let ccDeviceID = auth.currentIdentity.value?.station.ccdevice, ccDeviceID.isNotEmpty else {
                    return Single.just(nil)
                }
                return ds.load(ccDeviceID)
            }
            .filter { ccDevice in
                guard let _ = ccDevice else {
                    derror("Could not load Credit Card device associated with this Station.")
                    return false
                }
                return true
            }
            .filterNil()
    }
}
