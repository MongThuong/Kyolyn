//
//  OrderingService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Managing current Order.
class OrderManager {
    let disposeBag = DisposeBag()
    /// Hold the current editing Order by OrderDetail/Bills views.
    let order = BehaviorRelay<Order?>(value: nil)
    let itemSelected = PublishSubject<Item>()
    let optionSelected = PublishSubject<(Modifier, Option)>()
    
    var dataService: DataService { return SP.dataService }
    
    //    /// Hold the moving bill
    //    let movingBill = Variable<Bill?>(nil)
    
    init() {
        SP.authService.currentIdentity
            .asObservable()
            .filter { id in id == nil }
            .clearCurrentOrder()
            .subscribe()
            .disposed(by: disposeBag)
        
        order
            .asObservable()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    /// Modify he current order and save with given item.
    ///
    /// - Parameters:
    ///   - item: the item to modify with.
    ///   - task: the modification task.
    /// - Returns: the `Single` of the whole modification process.
    func modify<T>(_ purpose: String, with item: T, task: @escaping (T, Order) -> Single<(T, Order)?>) -> Single<(T, Order)?> {
        guard let order = self.order.value else {
            return Single.just(nil)
        }
        return Kiolyn.modify(order: order, purpose, with: item, task: task)
            .map { res in
                if let _ = res {
                    self.order.accept(order)
                }
                return res
        }
    }
    
    /// Modify the current order and save it if the returned result is positive.
    ///
    /// - Parameter task: the modification task to perform
    /// - Returns: the `Single` of the whole modification process
    func modify(_ purpose: String, _ task: @escaping (Order) -> Single<Order?>) -> Single<Order?> {
        guard let order = self.order.value else {
            return Single.just(nil)
        }
        return Kiolyn.modify(order: order, purpose, task: task)
            .map { res in
                if let _ = res {
                    self.order.accept(order)
                }
                return res
        }
    }
    
    /// Close the current `Order`.
    ///
    /// - Returns: `Single` of the closing result.
    func close() -> Single<Order?> {
        guard let order = self.order.value, order.isNotClosed,
            let employee = SP.authService.employee else {
                return Single.just(nil)
        }
        
        if order.isEmpty && order.orderNo == 0 {
            d("[OrderManager] (Closing) Deleting \(order)")
            return self.dataService.delete(order)
                .map { order -> Order? in
                    guard let order = order else {
                        return nil
                    }
                    d("[OrderManager] (Closing) Deleted \(order)")
                    // Clear current order
                    self.order.accept(nil)
                    return order
            }
        }
        
        return modify("closeOrder") { order in
            let order = order.close(by: employee)
            return Single.just(order)
            }
            .map { order in
                // Clear current order
                self.order.accept(nil)
                return order
        }
    }
}

/// Modify the given order and save with given item.
///
/// - Parameters:
///   - item: the item to modify with.
///   - task: the modification task.
/// - Returns: Single of the result.
func modify<T>(order: Order, _ purpose: String, with item: T, task: @escaping (T, Order) -> Single<(T, Order)?>) -> Single<(T, Order)?> {
    return task(item, order)
        .flatMap { res in
            guard let (item, order) = res else {
                return Single.just(nil)
            }
            d("[OrderManager] \(purpose) Modifying \(order)")
            order.updateCalculatedValues()
            return SP.dataService
                .save(order)
                .map { order -> (T, Order)? in
                    guard let order = order else {
                        return nil
                    }
                    d("[OrderManager] \(purpose) Modified \(order)")
                    SP.orderManager.order.accept(order)
                    return (item, order)
            }
    }
}

/// Modify the current order and save it if the returned result is positive.
///
/// - Parameter task: the modification task to perform
/// - Returns: the `Single` of the whole modification process
func modify(order: Order, _ purpose: String, task: @escaping (Order) -> Single<Order?>) -> Single<Order?> {
    return task(order)
        .flatMap { order in
            guard let order = order else {
                return Single.just(nil)
            }
            d("[OrderManager] \(purpose) Modifying \(order)")
            order.updateCalculatedValues()
            return SP.dataService
                .save(order)
                .map { order -> Order? in
                    guard let order = order else {
                        return nil
                    }
                    d("[OrderManager] \(purpose) Modified \(order)")
                    SP.orderManager.order.accept(order)
                    return order
            }
    }
}

/// Lock/Modify/Unlock given Order.
///
/// - Parameters:
///   - order: the `Order` to be manipulated.
///   - purpose: the purpose of the modification
///   - task: the modification task.
/// - Returns: Single of the whole process
func lock(andModify order: Order, _ purpose: String, task: @escaping (Order) -> Single<Order?>) -> Single<Order?> {
    return SP.dataService
        .lock(order: order)
        .flatMap { order -> Single<Order?> in
            guard let order = order else {
                return Single.just(nil)
            }
            return modify(order: order, purpose, task: task)
        }
        .catchError { error -> Single<Order?> in
            SP.dataService
                .unlockAllOrders()
                .map { _ -> Order? in nil}
        }
        .flatMap { order -> Single<Order?> in
            SP.dataService
                .unlockAllOrders()
                .map { order }
    }
}
