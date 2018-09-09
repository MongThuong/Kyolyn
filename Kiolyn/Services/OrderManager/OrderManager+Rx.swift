//
//  OrderManager+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Order manager related settings.
extension ObservableType where E == Order {
    /// 1. Unlock current Order
    /// 2. Lock new Order
    /// 3. Set as current Order
    ///
    /// - Returns: The `Observable` of the locking/setting result.
    func setCurrent() -> Observable<Order> {
        return self
            .unlockAllOrders()
            .lock()
            .filter { order in
                SP.orderManager.order.accept(order)
                return true
            }
            .filterNil()
    }
}

extension ObservableType {
    
    /// Clear current order operator.
    ///
    /// - Returns: The `Observable` of the clearing result.
    func clearCurrentOrder() -> Observable<E> {
        return self
            .unlockAllOrders()
            .filter { _ -> Bool in
                SP.orderManager.order.accept(nil)
                return true
        }
    }
        
    /// Convenient operator for modifying the current Order.
    ///
    /// - Parameters:
    ///   - purpose: the modification purpose.
    ///   - task: the modification task.
    /// - Returns: Observable result of the modification.
    func modify(currentOrder purpose: String, task: @escaping (Order) -> Single<Order?>) -> Observable<Order?> {
        return self.flatMap { _ in
            SP.orderManager.modify(purpose, task).asObservable().catchError { error -> Observable<Order?> in
                return Observable.just(nil)
            }
        }
    }
    
    /// Convenient operator for modifying the current Order.
    ///
    /// - Parameters:
    ///   - purpose: the modification purpose.
    ///   - task: the modification task.
    /// - Returns: Observable result of the modification.
    func modify(currentOrder purpose: String, task: @escaping (E, Order) -> Single<(E, Order)?>) -> Observable<(E, Order)?> {
        return self.flatMap { item in
            SP.orderManager.modify(purpose, with: item, task: task).asObservable().catchError{ error -> Observable<(Self.E, Order)?> in
                return Observable.just(nil)
            }
        }
    }
    
    /// Modify current order with given modal dialog
    ///
    /// - Parameters:
    ///   - purpose: the modification purpose.
    ///   - modal: the modal dialog use for modifying the order
    /// - Returns: Observable result of the modification.
    func modify(currentOrder purpose: String, modal: @escaping (Order) -> DialogViewModel<Order>) -> Observable<Order?> {
        return self.flatMap { _ in
            SP.orderManager.modify(purpose) { order in dmodal { modal(order) } }.asObservable().catchError{ error -> Observable<Order?> in
                return Observable.just(nil)
            }
        }
    }
    
    /// Modify current order with given modal dialog
    ///
    /// - Parameters:
    ///   - purpose: the modification purpose.
    ///   - modal: the modal dialog use for modifying the order
    /// - Returns: Observable result of the modification.
    func modify(currentOrder purpose: String, modal: @escaping (E, Order) -> DialogViewModel<(E, Order)>) -> Observable<(E, Order)?> {
        return self.flatMap { e in
            SP.orderManager.modify(purpose, with: e) { (e, order) in dmodal { modal(e, order) } }.asObservable().catchError({ error -> Observable<(Self.E, Order)?> in
                return Observable.just(nil)
            })
        }
    }
}
