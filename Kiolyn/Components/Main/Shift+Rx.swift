//
//  Shift+BusinessLogics.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/23/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    /// Make sure there is active shift and perform action correspondently.
    ///
    /// - Parameter task: The task to perform.
    func ensureActiveShift() -> Observable<Shift> {
        return self
            .flatMap { _ -> Single<Shift?> in
                // Check if there is opening shift, YES then reload it
                let ds = SP.dataService
                if let shift = ds.activeShift.value {
                    return Single.just(shift)
                }
                guard ds.isMain else {
                    dinfo("There is no opening shift. Please open a new shift on Main station and retry.")
                    return Single.just(nil)
                }
                // Ask for opening shift then perform task
                return dconfirm("There is no opening shift. Do you want to open a new shift?")
                    .flatMap { yes -> Single<Shift?> in
                        guard yes else { return Single.just(nil) }
                        // Got a good confirm, call the shift service to open new shift
                        return dprogress("", task: ds.openNewShift)
                            .catchError { error -> Single<Shift?> in
                                return Single.just(nil)
                            }
                            .map { shift in
                                if shift == nil {
                                    derror("Could not open new shift, please check log file for detail error.")
                                }
                                return shift
                            }
                    }
            }
            .filterNil()
    }
}
