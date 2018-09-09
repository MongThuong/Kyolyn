//
//  EditOrderItemDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/9/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias EditOrderItemDR = (OrderItem, Order)
typealias ModifierOptionVM = (Modifier, [Selectable<Option>])

/// For editing an order item
class EditOrderItemDVM: DialogViewModel<EditOrderItemDR> {
    var order: Order!
    var orderItem: OrderItem!
    
    /// `true` if order item is new or submitted and current user has the right to edit.
    var canEdit: Bool {
        return orderItem.isNew ||
            ((orderItem.isSubmitted || orderItem.isChecked)
                && employee.permissions.deleteEditSentItem)
    }
    
    /// Price can be adjusted either it is of open item or user has the price adjustment permisison.
    var canEditName: Bool {
        return orderItem.isOpenItem && canEdit
    }
    
    /// Price can be adjusted either it is of open item or user has the price adjustment permisison.
    var canEditPrice: Bool {
        return (orderItem.isOpenItem || employee.permissions.adjustPrice) && canEdit
    }
    
    var name: BehaviorRelay<String>!
    var samelineName: BehaviorRelay<String>!
    var count: BehaviorRelay<Double>!
    var price: BehaviorRelay<Double>!
    var note: BehaviorRelay<String>!
    var priceNote: BehaviorRelay<Double>!
    var togo: BehaviorRelay<Bool>!
    let printers = BehaviorRelay<[Selectable<Printer>]>(value: [])
    let modifiers = BehaviorRelay<[ModifierOptionVM]>(value: [])
    let subtotal = BehaviorRelay<Double>(value: 0)
    
    let viewStatus = BehaviorRelay<ViewStatus>(value: .loading)
    
    init(_ orderItem: OrderItem, of order: Order) {
        super.init()
        dialogTitle.accept("Edit Item")
        
        self.order = order
        self.orderItem = orderItem
        
        samelineName = BehaviorRelay(value: orderItem.samelineName)
        name = BehaviorRelay(value: orderItem.name)
        count = BehaviorRelay(value: orderItem.count)
        price = BehaviorRelay(value: orderItem.price)
        note = BehaviorRelay(value: orderItem.note)
        priceNote = BehaviorRelay(value: orderItem.priceNote)
        togo = BehaviorRelay(value: orderItem.togo)

        if orderItem.isOpenItem {
            _ = dialogDidAppear
                .flatMap { self.loadPrinters() }
                .bind(to: printers)
        } else {
            _ = dialogDidAppear
                .flatMap { self.loadModifierOptions() }
                .bind(to: modifiers)
        }

        // Calculate canSave and subtotal
        Driver
            .combineLatest(
                name.asDriver(),
                price.asDriver(),
                count.asDriver(),
                note.asDriver(),
                priceNote.asDriver(),
                togo.asDriver(),
                modifiers.asDriver(),
                printers.asDriver())
            .filter { _ in self.viewStatus.value.isNotLoading }
            .map { (name, price, count, note, priceNote, togo, modifiers, printers) -> Bool in
                orderItem.name = name
                orderItem.price = price
                orderItem.count = count
                orderItem.note = note
                orderItem.priceNote = priceNote
                orderItem.togo = togo
                if orderItem.isOpenItem {
                    orderItem.printers = printers
                        .filter { $0.isSelected }
                        .map { printer in BaseModel(id: printer.item.id) }
                } else {
                    // update modifiers
                    orderItem.modifiers =
                        // Maintain the list of global modifiers
                        orderItem.modifiers.filter { orderMod in orderMod.global || orderMod.custom } +
                        // and the new selected 
                        modifiers
                            .map { (modifier, options) -> OrderModifier? in
                                let selectedOptions = options
                                    .filter { $0.isSelected }
                                    .map { $0.item }
                                guard selectedOptions.isNotEmpty else { return nil }
                                return OrderModifier(modifier: modifier, selectedOptions: selectedOptions)
                            }
                            .filter { $0 != nil }
                            .map { $0! }
                }
                // update final subtotal
                orderItem.updateCalculatedValues()
                // update subtotal on UI
                self.subtotal.accept(orderItem.subtotal)
                // update the sameline
                self.samelineName.accept(orderItem.samelineName)

                // Check name and price for open item
                if orderItem.isOpenItem {
                    guard name.isNotEmpty && price >= 0 && price <= 999999 else {
                        return false
                    }
                } else if modifiers.isNotEmpty {
                    guard modifiers.all({ (modifier, options) in
                        // Is NOT required modifier
                        // OR else having at least one option selected
                        modifier.notRequired || options.any{ $0.isSelected }
                    }) else {
                        return false
                    }
                }
                // Make sure we got the good inputs
                guard count > 0 && count <= 99 && priceNote >= 0 && priceNote <= 999999 else {
                    return false
                }
                return true
            }
            .drive(canSave)
            .disposed(by: disposeBag)

        save.map { (orderItem, order) }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
    
    private func loadModifierOptions() -> Single<[ModifierOptionVM]> {
        viewStatus.accept(.loading)
        // Take all modifiers belong to a given item
        return dataService.load(modifiers: orderItem.itemID)
            .catchError { error -> Single<[Modifier]> in
                self.viewStatus.accept(.error(reason: error.localizedDescription))
                return Single.just([])
            } 
            .map { modifiers -> [ModifierOptionVM] in
                // Eliminate the one without options and global ones
                let selectableModifiers = modifiers
                    .filter { mod in
                        mod.name.isNotEmpty && mod.isNotGlobal && mod.options.isNotEmpty
                    }
                    .compactMap { modifier -> ModifierOptionVM in
                        let orderMod = self.orderItem.modifiers.first { $0.id == modifier.id }
                        let orderOptions = modifier.options
                            .map { opt -> Selectable<Option> in
                                let selected = orderMod?.options.contains { $0.id == opt.id } ?? false
                                return Selectable<Option>(opt, selected: selected)
                        }
                        return (modifier, orderOptions)
                }
                self.viewStatus.accept(.ok)
                return selectableModifiers
        }
    }
    
    private func loadPrinters() -> Single<[Selectable<Printer>]> {
        viewStatus.accept(.loading)
        return dataService.loadAll()
            .catchError { error -> Single<[Printer]> in
                self.viewStatus.accept(.error(reason: error.localizedDescription))
                return Single.just([])
            }
            .map { printers -> [Selectable<Printer>] in
                let selectablePrinters = printers.map { printer -> Selectable<Printer> in
                    let selected = self.orderItem.printers.contains { $0.id == printer.id }
                    return Selectable(printer, selected: selected)
                }
                self.viewStatus.accept(.ok)
                return selectablePrinters
        }
    }
}


