//
//  OrderDetailViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For filtering order item
enum OrderItemFilterType {
    case none
    case all
    case new
    case sent
    
    var text: String {
        switch self {
        case .none: return "NONE"
        case .all: return "ALL"
        case .new: return "NEW"
        case .sent: return "SENT"
        }
    }
}

/// Handling the display/interaction of an Order.
class OrderDetailViewModel: BaseViewModel {
    
    /// For controlling the selected order item
    let selectedOrderItems = BehaviorRelay<[String]>(value: [])
    let toggleSelectedItem = PublishSubject<OrderItem>()
    let applyFilter = PublishSubject<OrderItemFilterType>()
    
    /// Publish to trigger order creation.
    let newOrder = PublishSubject<Void>()
    /// Publish to trigger order editing.
    let editOrder = PublishSubject<Void>()
    /// Publish to trigger order extra editing.
    let editOrderExtra = PublishSubject<Void>()
    /// Publish to trigger order item editing.
    let editOrderItem = PublishSubject<OrderItem>()

    /// Publish to remove order item from current order.
    let remove = PublishSubject<OrderItem>()
    let clear = PublishSubject<Void>()
    let close = PublishSubject<Void>()
    let checkCloseCondition = PublishSubject<Void>()
    let delete = PublishSubject<Void>()
    let send = PublishSubject<Void>()
    let check = PublishSubject<Void>()
    let togo = PublishSubject<Void>()
    let hold = PublishSubject<Void>()
    let sendWithoutPrint = PublishSubject<Void>()
    let showBills = PublishSubject<Void>()
    
    // Settings Area
    let layoutScale = BehaviorRelay<CGFloat>(value: 1.0)
    let removeBill = PublishSubject<Void>()
    
    
    /// Create with service provider
    ///
    /// - Parameter provider: Service provider.
    override init() {
        super.init()

        // Show tables layout upon asking for new Order
        newOrder.show(main: .tablesLayout).disposed(by: disposeBag)

        editOrder
            .modify(currentOrder: "editOrder") { EditOrderDVM($0, true) }
            .subscribe()
            .disposed(by: disposeBag)

        editOrderExtra
            .modify(currentOrder: "editOrderExtra") { EditOrderExtraDVM($0) }
            .subscribe()
            .disposed(by: disposeBag)

        toggleSelectedItem
            .filter { oi in
                guard oi.isPaid else { return true }
                dinfo("This item is locked because it has already been paid.")
                return false
            }
            .flatMap { self.unbill(item: $0) }
            .map { orderItem -> [String] in
                
                // show items menu
                SP.navigation.orderingInteractionView.accept(OrderingInteractionViewType.menu)
                
                // return selected items
                var selectedItems = self.selectedOrderItems.value
                if let index = selectedItems.index(of: orderItem.id) {
                    selectedItems.remove(at: index)
                    return selectedItems
                } else  {
                    return selectedItems + [orderItem.id]
                }
            }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)
        
        // handle remove bill before apply Filter
        removeBill.modify(currentOrder: "removeBill") { order -> Single<Order?> in
            self.unbill(order: order)
        }
        .filter { order in order?.noBills ?? false}
        .show(ordering: .menu)
        .disposed(by: disposeBag)

        applyFilter
            .map { filter -> [String] in
                guard let order = self.orderManager.order.value else {
                    return []
                }
                switch filter {
                case .all:
                    return order.items
                        .filter { $0.isNotPaid && $0.isNotBilled }
                        .map { $0.id }
                case .new:
                    return order.items
                        .filter { $0.isNew }
                        .map { $0.id }
                case .sent:
                    return order.items
                        .filter { $0.isSubmitted }
                        .map { $0.id }
                case .none: return []
                }
            }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)
        
        
        editOrderItem
            .filter { item in
                guard item.isNotPaid else {
                    dinfo("This item is locked because it has already been paid.")
                    return false
                }
                return true
            }
            .flatMap { self.unbill(item: $0) }
            .modify(currentOrder: "editOrderItem") { (orderItem, order) in
                EditOrderItemDVM(orderItem, of: order)
            }
            .filterNil()
            .map { (orderItem, order) -> [String] in
                order.items
                    .filter { item in item.id == orderItem.id }
                    .map { item in item.id }
            }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)

        // Remove an OrderItem
        remove
            .modify(currentOrder: "removeItem") { (orderItem, order) -> Single<(OrderItem, Order)?> in
                guard let itemIndex = order.items.index(of: orderItem) else {
                    return Single.just(nil)
                }
                order.items.remove(at: itemIndex)
                return Single.just((orderItem, order))
            }
            .filterNil()
            .filter { _ in
                self.checkCloseCondition.onNext(())
                return true
            }
            .map { (orderItem, _) in
                self.selectedOrderItems.value.filter { item in
                    item != orderItem.id
                }
            }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)


        // 1. If there is no active order then create a new active order
        // 2. If the item required for modifiers then open the Edit Order Item dialog, otherwise just create new OrderItem based on the selected Item
        // 3. Send the new OrderItem to the active Order to adding by either increasing count of the same OrderItem or creating a new one
        orderManager.itemSelected
            // Make sure there is always an order (create new if needed)
            // this is to speed up the ordering experience
            .filter { item -> Bool in
                // if order exists and mutable, then just return the item/order
                if let order = self.orderManager.order.value, order.mutable {
                    return true
                }
                _ = dconfirm("Do you want to create new order?")
                    .asObservable()
                    .filter { $0 }
                    .show(main: .tablesLayout)
                return false
            }
            .flatMap { item -> Single<(Item, Bool)> in
                guard !item.isOpenItem else {
                    return Single.just((item, true))
                }
                return SP.dataService
                    .load(modifiers: item.id)
                    .map { modifiers in modifiers.any { $0.required } }
                    .map { (item, $0) }
            }
            .flatMap { (item, editBeforeAdd) -> Single<OrderItem?> in
                guard let order = self.orderManager.order.value else {
                    return Single.just(nil)
                }
                let orderItem = OrderItem(for: item)
                guard editBeforeAdd else {
                    return Single.just(orderItem)
                }
                return dmodal { EditOrderItemDVM(orderItem, of: order) }.map { $0?.0 }
            }
            .filterNil()
            .modify(currentOrder: "addItem") { orderItem, order -> Single<(OrderItem, Order)?> in
                let orderItem = order.add(item: orderItem)
                return Single.just((orderItem, order))
            }
            .filterNil()
            .map { [$0.0.id] }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)

        // 1. If there is no active order then create a new active order
        // 2. If the item required for modifiers then open the Edit Order Item dialog, otherwise just create new OrderItem based on the selected Item
        // 3. Send the new OrderItem to the active Order to adding by either increasing count of the same OrderItem or creating a new one
        orderManager.optionSelected
            .modify(currentOrder: "addOption") { (modOpt, order) -> Single<((Modifier, Option), Order)?> in
                let selectedItems = self.selectedOrderItems.value
                let items = order.items.filter { item in
                    // Item is selected
                    selectedItems.contains(item.id) &&
                    // Allow editing only when item is new or Submitted/Checked and current user have the correct permisison
                    (item.isNew || ((item.isChecked || item.isSubmitted) && self.employee.permissions.deleteEditSentItem))
                }
                guard items.isNotEmpty else {
                    return Single.just(nil)
                }
                let (modifier, option) = modOpt
                for item in items {
                    _ = order.add(option: option, of: modifier, to: item)
                }
                return Single.just((modOpt, order))
            }
            .subscribe()
            .disposed(by: disposeBag)

        send.modify(currentOrder: "setNewOrderNo") { order -> Single<Order?> in
                SP.dataService.set(newOrderNo: order)
            }
            .filter { order -> Bool in
                guard let _ = order else {
                    derror("Could not obtain new order no, please consult the log file for more detail")
                    return false
                }
                return true
            }
            .modify(currentOrder: "sendNewItems") { order -> Single<Order?> in
                let selectedItems = self.selectedOrderItems.value
                let submittedItems = order.items.filter { item in
                    selectedItems.contains(item.id) && item.isSubmitted
                }
                if submittedItems.isNotEmpty {
                    return dmodal { PrintItemsDVM(order, orderItems: submittedItems, type: .resend) }
                        .map { printRes -> Order? in
                            guard let (order, printedItems) = printRes else {
                                return nil
                            }
                            // Reset updated status
                            for oi in printedItems {
                                oi.isUpdated = false
                            }
                            return order
                    }
                } else if order.submittableItems.isNotEmpty {
                    return dmodal { PrintItemsDVM(order, orderItems: order.submittableItems, type: .send) }
                        .map { printRes -> Order? in
                            guard let (order, printedItems) = printRes else {
                                return nil
                            }
                            return order.save(items: printedItems)
                    }
                } else {
                    return Single.just(nil)
                }
            }
            .map { _ in [] }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)
        
        sendWithoutPrint
            .modify(currentOrder: "setNewOrderNo") { order -> Single<Order?> in
                SP.dataService.set(newOrderNo: order)
            }
            .filter { order -> Bool in
                guard let _ = order else {
                    derror("Could not obtain new order no, please consult the log file for more detail")
                    return false
                }
                return true
            }
            .modify(currentOrder: "saveNewItems") { order -> Single<Order?> in
                let order = order.save(items: order.submittableItems)
                return Single.just(order)
            }
            .map { _ in [] }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)

        clear.modify(currentOrder: "clearNewItems") { order -> Single<Order?> in
                guard order.newItems.isNotEmpty else {
                    return Single.just(nil)
                }
                order.items = order.items.filter { $0.isNotNew }
                return Single.just(order)
            }
            .filterNil()
            .filter { _ in
                self.checkCloseCondition.onNext(())
                return true
            }
            .map { order in self.update(selectedItems: order) }
            .bind(to: selectedOrderItems)
            .disposed(by: disposeBag)

        delete
            .withLatestFrom(orderManager.order)
            .filterNil()
            // If the checked items include items in CHECKED status, we need to ask for permission.
            // The permission is granted to perform more but the granted users won't be recorded.
            .flatMapLatest { order -> Observable<([OrderItem], Employee)> in
                let checkedItems = order.items.filter { item in
                    self.selectedOrderItems.value.contains(item.id)
                }
                // At least some items to do the action for
                guard checkedItems.any({ $0.isNew || $0.isSubmitted || $0.isChecked }) else {
                    return Observable.empty()
                }
                guard checkedItems.any({ $0.isSubmitted || $0.isChecked }) else {
                    return Observable.just((checkedItems, self.employee))
                }
                return require(permission: Permissions.DELETE_EDIT_SENT_ITEMS)
                    .asObservable()
                    .filterNil()
                    .map { (checkedItems, $0) }
            }
            .flatMapLatest { (checkedItems, emp) -> Observable<([OrderItem], Employee, String)> in
                // Ask for a reason when there is summitted/checked items
                guard checkedItems.any({ $0.isSubmitted || $0.isChecked }) else {
                    return Observable.just((checkedItems, emp, ""))
                }
                return dmodal { SelectAndEditReasonDVM(self.settings.voidOrderReasons) }
                    .asObservable()
                    .filterNil()
                    .map { reason in (checkedItems, emp, reason) }
            }
            .modify(currentOrder: "deleteItems") { (inputs, order) -> Single<(([OrderItem], Employee, String), Order)?> in
                let (checkedItems, emp, reason) = inputs
                guard let order = order.void(items: checkedItems, with: reason, by: emp) else {
                    return Single.just(nil)
                }
                return Single.just((inputs, order))
            }
            .subscribe(onNext: { args in
                guard let ((_, emp, reason), order) = args, order.isVoided else {
                    return
                }
                _ = SP.emailService
                    .send(voidOrder: order, inStore: self.store, byEmployee: emp, with: reason)
                    .subscribe()
            })
            .disposed(by: disposeBag)

        // Verify the close condition and trigger close after asking for user opinion
        checkCloseCondition
            .withLatestFrom(orderManager.order)
            .filter { order in
                guard let order = order else {
                    return false
                }
                return order.isNotClosed && order.allPaid || order.isEmpty
            }
            .confirm("Do you want to close the order also?")
            .mapToVoid()
            .bind(to: close)
            .disposed(by: disposeBag)

        // Close current Order
        close.flatMap { _ in self.closeOrder() }
            .clearCurrentOrder()
            .show(main: .tablesLayout)
            .disposed(by: disposeBag)

        togo.modify(currentOrder: "changeToGo") { order -> Single<Order?> in
                let selectedItems = self.selectedOrderItems.value
                let newItems = order.items.filter { item in
                    selectedItems.contains(item.id) && item.isNew
                }
                guard newItems.isNotEmpty else {
                    return Single.just(nil)
                }
                // If there is items that are not TOGO, mark all as TOGO
                // otherwise remove all TOGO marks
                let togo = newItems.any { $0.notTogo }
                for item in newItems {
                    item.togo = togo
                }
                return Single.just(order)
            }
            .subscribe()
            .disposed(by: disposeBag)

        hold.modify(currentOrder: "changeHold") { order -> Single<Order?> in
                let selectedItems = self.selectedOrderItems.value
                let newItems = order.items.filter { item in
                    selectedItems.contains(item.id) && item.isNew
                }
                guard newItems.isNotEmpty else {
                    return Single.just(nil)
                }
                // If there is items that are not HOLD, mark all as HOLD
                // otherwise remove all HOLD marks
                let hold = newItems.any { $0.notHold }
                for item in newItems {
                    item.hold = hold
                }
                return Single.just(order)
            }
            .subscribe()
            .disposed(by: disposeBag)

        // Check out items
        check.modify(currentOrder: "checkout") { order in Single.just(order.checkout()) }
            .show(ordering: .bills)
            .disposed(by: disposeBag)
        // Show bills
        showBills.show(ordering: .bills).disposed(by: disposeBag)
    }

    /// Handle Unbill
    ///
    /// - Parameters:
    ///     - order: Order
    ///     - orderItem: Selected Order Item to unbill. It's optional value
    /// - Returns: Single<Order?>
    fileprivate func unbill(order: Order, for orderItem: OrderItem? = nil) -> Single<Order?> {
        let paidItems = order.items.filter { item in
            return item.isPaid
        }
        
        let uncheckedBills = order.bills.filter { bill in
            // check bill paid
            guard bill.isNotPaid else { return false }
            
            // check case bill have select order item
            if let orderItem = orderItem {
                guard bill.items.any({ $0.id == orderItem.id }) else { return false }
            }
            
            // check case in bill have any item what also appear in paid bill
            return bill.items.any({ billItem -> Bool in
                paidItems.all({ paidItem -> Bool in
                    billItem.id != paidItem.id
                })
            })
        }
        let uncheckedItems = uncheckedBills.flatMap { $0.items }
        for billItem in uncheckedItems {
            guard let orderItem = order.items.first(where: { $0.id == billItem.id }) else {
                continue
            }
            orderItem.billedCount -= billItem.count
        }
        // Remove bills
        order.bills = order.bills.filter { bill in
            uncheckedBills.all { bill.id != $0.id }
        }
        return Single.just(order)
    }
    
    /// Update selected items to removed deleted items.
    ///
    /// - Parameter order: the order to update.
    /// - Returns: the updated list of selected items.
    private func update(selectedItems order: Order) -> [String] {
        return self.selectedOrderItems.value.filter { item in
            order.items.contains { $0.id == item }
        }
    }
    
    /// Close the current Order.
    ///
    /// - Returns: `Single` of the closing result.
    private func closeOrder() -> Single<Order?> {
        guard let order = self.orderManager.order.value, order.isNotClosed else {
            return Single.just(nil)
        }
        if order.isEmpty && order.orderNo == 0 {
            return self.dataService.delete(order)
                .map { order -> Order? in order }
                .catchError { error -> Single<Order?> in
                    derror(error)
                    return Single.just(nil)
            }
        }
        return self.orderManager.modify("closeOrder") { order in
            let order = order.close(by: self.employee)
            return Single.just(order)
        }
    }
    
    /// Ask user for confirmation before unbilling the given order item.
    ///
    /// - Parameter orderItem: the order item to be unbilled
    /// - Returns: Single of the unbilling result.
    private func unbill(item orderItem: OrderItem) -> Maybe<OrderItem> {
        // If the item is not billed then it is allowed to be selected
        guard orderItem.billedCount > 0 else {
            return Maybe.just(orderItem)
        }
        
        // Given that user is in Order Detail and the bills are shown, when user clicks on the exclamation point, then remove all open bills and check the item.
        return orderManager.modify("unbillItem", { order -> Single<Order?> in
            self.unbill(order: order, for: orderItem)
        })
        .filter { order in order?.noBills ?? false }
        .map { _ in orderItem}
    }
}
