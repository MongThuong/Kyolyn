//
//  Database+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension Database {
    
    /// async as an operator
    ///
    /// - Parameter task: the query/update to perform.
    /// - Returns: single of the action.
    func async<T>(_ task: @escaping () throws -> T) -> Single<T> {
        return Single<T>
            .create { single -> Disposable in
                self.async {
                    do {
                        let res = try task()
                        DispatchQueue.main.async {
                            single(.success(res))
                        }
                    } catch (let err) {
                        DispatchQueue.main.async {
                            single(.error(err))
                        }
                    }
                }
                return Disposables.create()
            }
    }
}
