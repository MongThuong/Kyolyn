//
//  OrdersViewModelTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/11/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxTest
import RxSwift
import RxBlocking
@testable import Kiolyn

class OrdersViewModelTests: BaseTests {
    override public func spec() {
        let storeID = "17021812551554" // Nam Hoa
        
        beforeSuite {
            self.preload(localDbName: "namhoa")
            self.saveTestStore(storeID: storeID)
            _ = try! self.authService.signin(storeID, passkey: "11111", mac: "9CB70D793fb8")
            _ = self.dataService.openNewShift()
        }
        
        describe("Orders") {
            describe("list") {
                context("having no orders") {
                    it("showing no orders") {
                        waitUntil(timeout: 10, action: { done in
                            let vm = OrdersViewModel()
                            _ = vm.data.drive(onNext: { data in
                                expect(data.summary.count) == 0
                                done()
                            })
                            vm.reload.onNext()
                        })
                    }
                }
                context("having orders") {
                    beforeEach {
                        let area: Area = self.database.load("17021812202523")!
                        let table: Table = area.tables.first { $0.id == "17021812202524"}!
                        let order = try! Order.new(in: self.database.database!, store: self.authService.currentIdentity!.store, shift: self.dataService.activeShift!, employee: self.authService.currentIdentity!.employee, area: area, table: table)
                        // Moods
                        let item: Item = self.database.load("17021812585131")!
                        let orderItem = OrderItem(for: item)
                        orderItem.count = 10
                        orderItem.updateCalculatedValues()
                        order.items.append(orderItem)
                        // Color
                        let modifier: Modifier = self.database.load("17030317310541")!
                        let options = Array(modifier.options[0..<2])
                        let orderModifier = OrderModifier(modifier: modifier, selectedOptions: options)
                        orderItem.modifiers.append(orderModifier)
                        orderItem.updateCalculatedValues()
                        order.updateCalculatedValues()
                        try! self.database.save(order)
                    }
                    
                    it("showing areas/tables with orders") {
                        waitUntil(timeout: 10, action: { done in
                            let vm = OrdersViewModel()
                            _ = vm.data.drive(onNext: { data in
                                expect(data.summary.count) == 1
                                done()
                            })
                            vm.reload.onNext()
                        })
                    }
                }
            }
            
            describe("selected orders") {
                let vm = OrdersViewModel()
                it("empty by default") {
                    expect(vm.checkedOrders.value.count) == 0
                }
                it("change button statuses on changed") {
                    
                }
            }
            
            describe("pagination") {
                
            }
        }
    }
}
