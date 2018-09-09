 //
//  DataService+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType where E == Order {
    
    /// Lock operator, receive the next Order, lock it, return the fresh Order
    /// and pass down the stream
    ///
    /// - Returns: `Observalbe` of the new locked `Order`
    func lock() -> Observable<Order?> {
        return self.flatMap { order -> Single<Order?> in
            SP.dataService
                .lock(order: order)
                .catchError { error -> Single<Order?> in
                    derror(error)
                    return Single.just(nil)
                }
        }
    }
}
 
extension ObservableType {    
    /// Unlock all orders operators.
    ///
    /// - Returns: the `Observable` unlocking result.
    func unlockAllOrders() -> Observable<E> {
        return self.flatMap { e -> Single<E> in
            SP.dataService
                .unlockAllOrders()
                .map { _ in e }
        }
    }
}
 
extension ObservableType where E: BaseModel {
    /// Save model operator.
    ///
    /// - Returns: Observalbe of the same object but got saved.
    func save() -> Observable<E> {
        return self
            .flatMap { model in
                SP.dataService
                    .save(model)
                    .catchError { error -> Single<E?> in
                        derror(error)
                        return Single.just(nil)
                }
            }
            .filterNil()
    }
    /// Delete model operator.
    ///
    /// - Returns: Observalbe of the same object but got saved.
    func delete() -> Observable<E> {
        return self
            .flatMap { model in
                SP.dataService
                    .delete(model)
                    .catchError { error -> Single<E?> in
                        derror(error)
                        return Single.just(nil)
                }
            }
            .filterNil()
    }
}

