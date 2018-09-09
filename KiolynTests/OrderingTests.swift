//
//  OrderTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/30/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

public class OrderingTests: BaseTests {
    
    func test(with test: @escaping (Shift) -> Void) {
        waitUntil(action: { done in
            self.dataService.openNewShift()
                .then(execute: { shift -> Void in
                    guard let shift = shift else {
                        fail("Could not open new shift")
                        return done()
                    }
                    test(shift)
                    done()
                })
                .catch(execute: { error in
                    fail(error.localizedDescription)
                    done()
                })
        })
    }
    
    override public func spec() {
        
        let storeID = "17021812551554" // Nam Hoa
        
        beforeSuite {
            self.preload(localDbName: "namhoa")
            self.saveTestStore(storeID: storeID)
            _ = try! self.authService.signin(storeID, passkey: "11111", mac: "9CB70D793fb8")
        }
        
        describe("Order") {
            
            it("can be created with order item/modifier") {
                self.test(with: { shift in
                    let order = try! Order.new(in: self.database.database!, store: self.authService.currentIdentity!.store, shift: shift, employee: self.authService.currentIdentity!.employee)
                    // Moods
                    let item: Item = self.database.load("17021812585131")!
                    let orderItem = OrderItem(for: item)
                    orderItem.count = 10
                    orderItem.updateCalculatedValues()
                    expect(orderItem.isNew) == true
                    expect(orderItem.subtotal) == 1200.00
                    order.items.append(orderItem)
                    // Color
                    let modifier: Modifier = self.database.load("17030317310541")!
                    let options = Array(modifier.options[0..<2])
                    let orderModifier = OrderModifier(modifier: modifier, selectedOptions: options)
                    orderItem.modifiers.append(orderModifier)
                    orderItem.updateCalculatedValues()
                    expect(orderItem.subtotal) == 1235.00
                    expect(orderItem.noModifierSubtotal) == 1200.00
                    order.updateCalculatedValues()
                    expect(order.total) == 1235.00
                    expect(order.hasRevision) == false
                    try! self.database.save(order)
                    expect(order.hasRevision) == true
                    expect(order.id).toNot(beNil())
                    
                    // Now reload it to make sure we get what we want
                    let reloadedOrder: Order = self.database.load(order.id)!
                    expect(reloadedOrder.total) == 1235.00
                    expect(reloadedOrder.items.first).toNot(beNil())
                    expect(reloadedOrder.items.first!.subtotal) == 1235.00
                    expect(reloadedOrder.items.first!.noModifierSubtotal) == 1200.00
                })
            }
        }
        
        describe("Order Detail View Model") {
            let vm = OrderDetailViewModel()

            it("can checkout items") {
                self.test(with: { shift in
                    let order = try! Order.new(in: self.database.database!, store: self.authService.currentIdentity!.store, shift: shift, employee: self.authService.currentIdentity!.employee)
                    // Moods
                    let item: Item = self.database.load("17021812585131")!
                    let orderItem = OrderItem(for: item)
                    orderItem.count = 10
                    orderItem.updateCalculatedValues()
                    order.items.append(orderItem)
                    order.updateCalculatedValues()
                    expect(order.unbilledItems).to(beEmpty())
                    
                    vm.submit(items: order.items, of: order)
                    expect(order.unbilledItems).toNot(beEmpty())
                    
                    expect(order.bills).to(beEmpty())
                    vm.checkout(order: order)
                    expect(order.bills.count) == 1
                    expect(order.bills.first).toNot(beNil())
                    expect(order.bills.first?.total) == order.total
                    
                    let reloadedOrder: Order = self.database.load(order.id)!
                    expect(reloadedOrder.bills.count) == 1
                })
            }
            
            it("can pay a bill") {
                self.test(with: { shift in
                    let store = self.authService.currentIdentity!.store
                    let employee = self.authService.currentIdentity!.employee
                    let order = try! Order.new(in: self.database.database!, store: store, shift: shift, employee: employee)
                    // Moods
                    let item: Item = self.database.load("17021812585131")!
                    let orderItem = OrderItem(for: item)
                    orderItem.count = 10
                    orderItem.updateCalculatedValues()
                    order.items.append(orderItem)
                    order.updateCalculatedValues()
                    vm.submit(items: order.items, of: order)
                    vm.checkout(order: order)
                    let bill = order.bills.first
                    expect(bill).toNot(beNil())
                    let transaction = try! Transaction.forCash(in: self.database.database!, store: store, shift: shift, employee: employee, order: order, bill: bill!, amount: bill!.total, subPaymentType: nil)
                    
                    vm.pay(bill: bill!, for: order, with: transaction)
                    let reloadedTrans: Transaction? = self.database.load(transaction.id)
                    expect(reloadedTrans).toNot(beNil())
                    expect(reloadedTrans!.transType) == TransactionType.cash
                    expect(reloadedTrans!.approvedAmount) == bill!.total
                })
            }
        }        
    }
}
