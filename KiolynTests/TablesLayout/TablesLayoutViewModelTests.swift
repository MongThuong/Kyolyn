//
//  TablesLayoutViewModelTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/8/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxTest
import RxExpect
import RxSwift
import RxCocoa
@testable import Kiolyn

fileprivate class LoadAreaMockDataService: DataService {
    let scheduler: ImmediateSchedulerType
    init(scheduler: ImmediateSchedulerType) {
        self.scheduler = scheduler
    }
    
//    override func loadAll<T>() -> Single<[T]> where T : BaseModel {
//        guard T.self == Area.self else {
//            return super.loadAll()
//        }
//        let db = SP.database
//        let areas: [Area] = [
//            db.new(model: ["name": "Dine-In"]) as! Area
//        ]
//        return Single<[T]>.just(areas as! [T], scheduler: scheduler)
//    }
}

fileprivate class MockAuthenticationService: AuthenticationService {
    func verify(passkey: String, havingPermission permission: String) -> PrimitiveSequence<SingleTrait, Employee?> {
        fatalError("Must be mocked")
    }
    
    var currentIdentity: BehaviorRelay<Identity?> {
        let db = SP.database
        let store: Store = db.new(model: [:]) as! Store
        let station: Station = db.new(model: ["main": true]) as! Station
        let employee: Employee = db.new(model: [:]) as! Employee
        let settings: Settings = db.new(model: [:]) as! Settings
        let id = Identity(store: store, station: station, employee: employee, settings: settings)
        return BehaviorRelay<Identity?>(value: id)
    }
    
    func signin(_ store: Store, station: Station, withPasskey passkey: String) -> PrimitiveSequence<SingleTrait, Identity> {
        fatalError("Must be mocked")
    }
    
    func signout() {
        fatalError("Must be mocked")
    }
}

class TablesLayoutViewModelTests: BaseTests {
    override func spec() {
        super.spec()
        
        
        describe("areas") {
            it("should load all available ares upon reloadAreas") {
                SP.container.register(.singleton) {  }
                let vm = TablesLayoutViewModel()
                let test = RxExpect()
                let ds = LoadAreaMockDataService(scheduler: test.scheduler)
                SP.container.register(.singleton) { ds as DataService }
                test.retain(vm)
                test.input(vm.reloadAreas, [Recorded.next(50, ())])
                test.assert(vm.areas) { events in
                    expect(events.map { $0.value.element?.count }).to(equal([0, 4]))
                }
            }
//            it("should clear upon signing out") {
//                self.signin { done in
//                    let vm = TablesLayoutViewModel()
//                    let test = RxExpect()
//                    test.retain(vm)
//                    test.input(vm.reloadAreas, [Recorded.next(50, ())])
//                    test.scheduler.scheduleAt(100) {
//                       NotificationCenter.default.post(Notification(name: .klSignedOut))
//                    }
//                    test.assert(vm.areas) { events in
//                        expect(events.map { $0.value.element?.count }).to(equal([0, 4]))
//                        done()
//                    }
//                }
//            }
        }

//        describe("Table Layout") {
//            describe("Areas") {
//
//                context("having no orders") {
//                    it("showing areas/tables only") {
//                        waitUntil(timeout: 10, action: { done in
//                            let vm = TablesLayoutViewModel()
//                            _ = vm.areas.asDriver().drive(onNext: { areas in
//                                expect(areas.count) == 4
//                                expect(areas.first?.area.name) == "Dine-In"
//                                expect(areas.first?.area.tables.count) == 5
//                                expect(areas.first?.area.tables.first?.name) == "Dine-In 1"
//                                expect(areas.first?.area.tables.first?.shape) == .rectangle
//                                expect(areas.first?.area.tables.first?.left) == 3.0
//                                expect(areas.first?.area.tables.first?.top) == 3.0
//                                expect(areas.first?.area.tables.first?.angle) == 0.0
//                                expect(areas.first?.area.tables.first?.width) == 90.0
//                                expect(areas.first?.area.tables.first?.height) == 90.0
//                                expect(areas.first?.tables.count) == 5
//                                expect(areas.first?.tables.first?.hasOrders) == false
//                                expect(areas.first?.tables.first?.orders.count) == 0
//                                done()
//                            })
//                            vm.reload.onNext()
//                        })
//                    }
//                }
//
//                context("having orders") {
//                    beforeEach {
//                        let area: Area = self.database.load("17021812202523")!
//                        let table: Table = area.tables.first { $0.id == "17021812202524"}!
//                        let order = try! Order.new(in: self.database.database!, store: self.authService.currentIdentity!.store, shift: self.dataService.activeShift!, employee: self.authService.currentIdentity!.employee, area: area, table: table)
//                        // Moods
//                        let item: Item = self.database.load("17021812585131")!
//                        let orderItem = OrderItem(for: item)
//                        orderItem.count = 10
//                        orderItem.updateCalculatedValues()
//                        order.items.append(orderItem)
//                        // Color
//                        let modifier: Modifier = self.database.load("17030317310541")!
//                        let options = Array(modifier.options[0..<2])
//                        let orderModifier = OrderModifier(modifier: modifier, selectedOptions: options)
//                        orderItem.modifiers.append(orderModifier)
//                        orderItem.updateCalculatedValues()
//                        order.updateCalculatedValues()
//                        try! self.database.save(order)
//                    }
//
//                    it("showing areas/tables with orders") {
//                        waitUntil(timeout: 10, action: { done in
//                            let vm = TablesLayoutViewModel()
//                            _ = vm.areas.asDriver().drive(onNext: { areas in
//                                expect(areas.count) > 0
//                                expect(areas.first?.tables.count) > 0
//                                expect(areas.first?.tables.first?.hasOrders) == true
//                                expect(areas.first?.tables.first?.orders.count) == 1
//                                done()
//                            })
//                            vm.reload.onNext()
//                        })
//                    }
//                }
//            }
//        }
    }
}
