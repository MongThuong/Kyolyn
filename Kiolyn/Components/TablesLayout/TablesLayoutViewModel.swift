//
//  TablesLayoutViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AwaitKit

/// Define the type of moving mode.
///
/// - none: Not in moving mode.
/// - combine: Combining mode.
/// - move: Moving mode.
enum MovingModeType {
    case combine
    case move
}

/// Delivered filter
///
/// - pending: not yet delivered
/// - delivered: already delivered
/// - all: both
enum DeliveredFilter: String {
    case pending = "PENDING"
    case delivered = "DELIVERED"
    case all = "ALL"
}

/// View model for tables layout
class TablesLayoutViewModel: BaseViewModel {
    /// Publish to either reload all or just orders
    let reload = PublishSubject<Void>()
    /// Publish to this to force a reloading of Areas/Tables
    let reloadAreas = PublishSubject<Void>()
    /// Publish to this to force a reloading of Orders
    let reloadOrders = PublishSubject<Void>()

    let open = PublishSubject<Void>()
    let addOrder = PublishSubject<Void>()

    let printCheck = PublishSubject<Void>()
    let pay = PublishSubject<Void>()
    let payByCard = PublishSubject<Void>()

    let move = PublishSubject<Void>()
    let moveTo = PublishSubject<(Order, Area, Table?)>()
    let combine = PublishSubject<Void>()
    let combineWith = PublishSubject<(Order, TableViewModel)>()
    

    let editCustomer = PublishSubject<Order>()
    let editDriver = PublishSubject<Order>()
    let editDelivered = PublishSubject<Order>()

    let areas = BehaviorRelay<[AreaViewModel]>(value: [])
    let selectedArea = BehaviorRelay<AreaViewModel?>(value: nil)
    let selectedOrder = BehaviorRelay<(MovingModeType, Order)?>(value: nil)
    let selectedTable = BehaviorRelay<TableViewModel?>(value: nil)

    let deliveredFilters = BehaviorRelay<[DeliveredFilter]>(value: [.pending, .delivered, .all])
    let selectedFilter = BehaviorRelay<DeliveredFilter>(value: .pending)

    override init() {
        super.init()
        
        reload.filter { self.areas.value.isEmpty }.bind(to: reloadAreas).disposed(by: disposeBag)
        reload.filter { self.areas.value.isNotEmpty }.bind(to: reloadOrders).disposed(by: disposeBag)

        // Reload all new areas
        reloadAreas
            .flatMapLatest { _ -> Single<[Area]> in self.dataService.loadAll() }
            .asDriver(onErrorJustReturn: [])
            .map { areas in areas.map { AreaViewModel($0, root: self) }}
            .drive(areas)
            .disposed(by: disposeBag)
        // Clear areas upon signing out
        SP.authService.currentIdentity
            .asDriver()
            .filter { $0 == nil }
            .map { _ -> [AreaViewModel] in [] }
            .drive(areas)
            .disposed(by: self.disposeBag)
        // Select first area when areas is updated
        areas
            .asDriver()
            .map { $0.first }
            .filterNil()
            .drive(selectedArea)
            .disposed(by: disposeBag)
        areas
            .asDriver()
            .map { _ in }
            .drive(reloadOrders)
            .disposed(by: disposeBag)
        // Reload orders based on areas changed or reloadOrders request
        reloadOrders
            .subscribe(onNext: { _ in
                for area in self.areas.value {
                    area.reload(orders: self.selectedFilter.value)
                }
            })
            .disposed(by: disposeBag)
        
        // Reload orders when remote changed
        SP.dataService.remoteOrderChanged
            .map { orderIDs -> [AreaViewModel] in
                let areas = self.areas.value
                // Update the related areas by searching the arSaea for matching order
                let relatedAreas = areas.filter { area in
                    area.orders.value.any { order in
                        orderIDs.contains(order.id)
                    }
                }
                // Now try to update the area that did not contains the order, but should be now
                let otherAreas = orderIDs
                    .map { id -> AreaViewModel? in
                        do {
                            if let order: Order = try await(self.dataService.load(id)) {
                                return areas.first(where: { areaVM in areaVM.area.id == order.area })
                            }
                        } catch {
                            w("[TablesLayout] Error reloading on remote order change \(error)")
                        }
                        return nil
                }
                return relatedAreas + otherAreas.filterNil()
            }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { areas in
                for area in areas {
                    area.reload(orders: self.selectedFilter.value)
                }
            })
            .disposed(by: disposeBag)

        // Clear selected table on area changed
        selectedArea
            .asObservable()
            .filterNil()
            .distinctUntilChanged()
            .map { _ -> TableViewModel? in nil }
            .bind(to: selectedTable)
            .disposed(by: disposeBag)
        // Update area based on area/filter changed
        Observable.combineLatest(
            selectedArea.asObservable(),
            selectedFilter.asObservable())
            .subscribe(onNext: { (area, filter) in
                area?.reload(orders: filter)
            })
            .disposed(by: disposeBag)

        // Select and show order
        open.ensureActiveShift()
            .withLatestFrom(selectedTable)
            .filterNil()
            .filter { table -> Bool in
                // If no order is in there, stop this sequence and move to addOrder
                guard table.orders.value.isNotEmpty else {
                    self.addOrder.onNext(())
                    return false
                }
                return true
            }
            .selectOrder()
            .setCurrent()
            // open the ordering view if user did not cancel the editing dialog
            .show(ordering: .menu)
            .disposed(by: disposeBag)

        printCheck
            .withLatestFrom(selectedTable)
            .filterNil()
            .selectOrder { (table, lockedOrders) in
                table.orders.value.filter { order in
                    lockedOrders.isNotLocked(order) && order.isNotNew && order.isNotClosed
                }
            }
            .lock(andModify: "printCheck") { order -> Single<Order?> in
                _ = order.checkout()
                return dmodal { PrintBillDVM(of: order, type: .check) }
                    .map { args -> Order? in
                        guard let (order, _) = args else {
                            return nil
                        }
                        return order.check(bill: nil)
                }
            }
            .bind(to: reloadOrders)
            .disposed(by: disposeBag)
        
        pay.withLatestFrom(selectedTable)
            .filterNil()
            .selectOrder { (table, lockedOrders) in
                table.orders.value.filter { order in
                    lockedOrders.isNotLocked(order) && order.isNotNew && order.isNotClosed
                }
            }
            .lock(andModify: "payBill") { order -> Single<Order?> in
                // Check out first
                _ = order.checkout()
                guard let bill = order.bills.first(where: { $0.isNotPaid }) else {
                    return dconfirm("All bills are already paid. Do you want to open the Order instead?")
                        .map { yes -> Order? in yes ? order : nil }
                }
                return dmodal { PayBillDVM(bill, of: order) }
                    .flatMap { payBillInfo in
                        guard let pbi = payBillInfo else {
                            return Single.just(nil)
                        }
                        return Kiolyn.pay(bill: pbi)
                }
            }
            .show(ordering: .bills)
            .disposed(by: disposeBag)

        payByCard
            .withLatestFrom(selectedTable)
            .filterNil()
            .selectOrder { (table, lockedOrders) in
                table.orders.value.filter { order in
                    lockedOrders.isNotLocked(order) && order.isNotNew && order.isNotClosed
                }
            }
            .lock(andModify: "payBillByCard") { order -> Single<Order?> in
                // Check out first
                _ = order.checkout()
                guard let bill = order.bills.first(where: { $0.isNotPaid }) else {
                    return dconfirm("All bills are already paid. Do you want to open the Order instead?")
                        .map { yes -> Order? in yes ? order : nil }
                }
                let cardPaymentType = CardPaymentType(from: self.settings)
                let payInfo: PayBillInfo = (order, bill, cardPaymentType, bill.total, nil)
                return Kiolyn.pay(bill: payInfo)
            }
            .show(ordering: .bills)
            .disposed(by: disposeBag)
        
        // Select and move order
        move.withLatestFrom(selectedTable)
            .filterNil()
            .selectOrder()
            .map { (MovingModeType.move, $0) }
            .bind(to: selectedOrder)
            .disposed(by: disposeBag)

        // Select and combine order
        combine
            .withLatestFrom(selectedTable.asObservable())
            .filterNil()
            .selectOrder()
            .map { (MovingModeType.combine, $0) }
            .bind(to: selectedOrder)
            .disposed(by: disposeBag)

        // Add Order command
        addOrder
            .ensureActiveShift()
            .flatMap { self.new(order: $0) }
            .filterNil()
            .flatMap { (area, order) -> Single<Order?> in
                if area.customerInfoPrompt || area.noOfGuestPrompt {
                    // Show Edit order dialog first
                    let res = dmodal { () -> EditOrderDVM in EditOrderDVM(order, true) }
                    // If service fee is not required, then return the result
                    guard area.serviceFeePrompt else { return res }
                    // ... otherwise show the service fee editting
                    return res.flatMap { order in
                        guard let order = order else {
                            return Single.just(nil)
                        }
                        return dmodal {
                            EditOrderExtraDVM(order, showTab: 3)
                        }
                    }
                } else if area.serviceFeePrompt {
                    return dmodal { EditOrderExtraDVM(order, showTab: 3) }
                } else {
                    return Single<Order?>.just(order)
                }
            }
            .filterNil()
            .save()
            .setCurrent()
            .show(ordering: .menu)
            .disposed(by: disposeBag)
                
        moveTo
            .flatMap { arg -> Single<Order?> in
                let (order, area, table) = arg
                return lock(andModify: order, "moveToDifferentTable") { order in
                    order.area = area.id
                    order.areaName = area.name
                    order.table = table?.id ?? ""
                    order.tableName = table?.name ?? ""
                    return Single.just(order)
                }
            }
            .filterNil()
            .filter { order in
                // Clear the currently selected order
                self.selectedOrder.accept(nil)
                // Reselect the selected table
                self.selectedTable.accept(self.selectedArea.value?.tables.value.first {
                    $0.table.id == order.table
                })
                return true
            }
            .mapToVoid()
            .bind(to: reloadOrders)
            .disposed(by: disposeBag)

        combineWith
            .flatMap { args -> Single<[Order]?> in
                let (order, tableVM) = args
                return Kiolyn
                    .select(order: tableVM) { (table, lockedOrders) -> [Order] in
                        table.orders.value.filter {
                            // included only not-being-locked orders if requested
                            lockedOrders.isNotLocked($0) &&
                                // included only editables orders if requested
                                !$0.isClosed && $0.bills.isEmpty &&
                                // exclude the given order
                                $0.id != order.id
                        }
                    }.map { selectedOrder in
                        guard let targetOrder = selectedOrder else {
                            return nil
                        }
                        return [targetOrder, order]
                }
            }
            .filterNil()
            .flatMap { orders in Kiolyn.merge(orders: orders) }
            .filter { order in
                guard let order = order else { return false }
                // Clear the currently selected order
                self.selectedOrder.accept(nil)
                // Select the target table
                self.selectedTable.accept(self.selectedArea.value?.tables.value.first {
                    $0.table.id == order.table
                })
                return true
            }
            .mapToVoid()
            .bind(to: reloadOrders)
            .disposed(by: disposeBag)

        editCustomer
            .lock(andModify: "editCustomer") { order in
                dmodal { EditCustomerDVM(order) }
            }
            .bind(to: reloadOrders)
            .disposed(by: disposeBag)
        editDriver
            .lock(andModify: "editCustomer") { order in
                dmodal { EditDriverDVM(order) }.map { _ in order }
            }
            .bind(to: reloadOrders)
            .disposed(by: disposeBag)
        editDelivered
            .lock(andModify: "editDeliveryStatus") { order in
                dconfirm("Order delivered?").map { yes in
                    if yes {
                        order.delivered = true
                        return order
                    } else {
                        return nil
                    }
                }
            }
            .bind(to: reloadOrders)
            .disposed(by: disposeBag)
    }
    
    private func new(order shift: Shift) -> Single<(Area, Order)?> {
        return Single<(Area, Order)?>.create { single in
            let disposable = Disposables.create()
            guard let area = self.selectedArea.value?.area else {
                single(.success(nil))
                return disposable
            }
            let tax = self.settings.defaultTax ?? Tax.noTax
            if area.isAutoIncrement {
                let order = Order(inStore: self.store, shift: shift, employee: self.employee, tax: tax, discount: Discount.noDiscount, serviceFeeTax: 0.0, area: area, table: nil)
                if area.isDelivery {
                    _ = self.dataService.loadDefaultDriver()
                        .subscribe(onSuccess: { driver in
                            if let driver = driver {
                                order.driver = driver.id
                                order.driverName = driver.name
                            }
                            single(.success((area, order)))
                        })
                } else {
                    single(.success((area, order)))
                }
            } else {
                // Make sure a table is selected
                guard let table = self.selectedTable.value?.table else {
                    single(.success(nil))
                    return disposable
                }
                let order = Order(inStore: self.store, shift: shift, employee: self.employee, tax: tax, discount: Discount.noDiscount, serviceFeeTax: self.settings.groupGratuityTax, area: area, table: table)
                single(.success((area, order)))
            }
            
            return disposable
        }
    }
}

fileprivate extension ObservableType where E == Order {
    
    /// Convenient operator for lock and modify order with filtering for nil and return void.
    ///
    /// - Parameters:
    ///   - purpose: the modification purpose.
    ///   - task: the modification task.
    /// - Returns: `Observable` of the modification result.
    func lock(andModify purpose: String, task: @escaping (Order) -> Single<Order?>) -> Observable<()> {
        return self
            .flatMap { order -> Single<Order?> in
                Kiolyn.lock(andModify: order, purpose, task: task)
            }
            .filterNil()
            .mapToVoid()
    }
}

fileprivate typealias SelectOrderFilter = (TableViewModel, [String: String]) -> [Order]

fileprivate let defaultSelectOrderFilter: SelectOrderFilter = { (table, lockedOrders) in
    // filter the locked orders
    table.orders.value.filter { lockedOrders.isNotLocked($0) }
}

fileprivate extension ObservableType where E == TableViewModel {
    /// Select Order from a stream of TableViewModel.
    ///
    /// - Parameter filter: The filter of selectable `Order`s
    /// - Returns: Observable of the selected `Order`.
    func selectOrder(_ filter: @escaping SelectOrderFilter = defaultSelectOrderFilter) -> Observable<Order> {
        return self
            .flatMap { table -> Single<Order?> in
                select(order: table, filter: filter)
            }
            .filterNil()
    }
}

fileprivate func select(order table: TableViewModel, filter: @escaping SelectOrderFilter) -> Single<Order?> {
    let lockedOrders = SP.dataService.lockedOrders.value
    let orders = filter(table, lockedOrders)
    guard orders.isNotEmpty else {
        return Single.just(nil)
    }
    guard orders.count > 1 else {
        return Single.just(orders.first)
    }
    return dmodal {
        SelectOrderDVM(orders, withTitle: "Select Order \(table.area.name) / \(table.table.name)")
    }
}

fileprivate func merge(orders: [Order]) -> Single<Order?> {
    let ds = SP.dataService
    return async {
        defer {
            _ = ds.unlockAllOrders().subscribe()
        }
        do {
            let orders = try await(ds.lock(orders: orders))
            guard orders.count > 1 else {
                derror("Require at least 2 Orders to merge.")
                return nil
            }
            let mergedOrders = orders.slice(start: 1, end: nil)
            let toOrder = orders.first!.merge(orders: mergedOrders)
            let mergedOrder = try await(ds.merge(order: toOrder, from: mergedOrders))
            return mergedOrder
        } catch (let error) {
            derror(error)
            return nil
        }
    }
}


