//
//  LoginViewModelTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/2/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
import RxExpect
import SwiftyUserDefaults
@testable import Kiolyn

public class LoginViewModelTests: BaseTests {
    override public func spec() {

        let db = newCouchbaseTestDatabase()
        
        beforeEach {
            SP.container.register { db as Database }
            Defaults[UserDefaults.lastStoreID] = ""
        }
        
        describe("storeID") {
            it("should has the value stored in user default") {
                let lastStoreID = NSUUID().uuidString
                Defaults[UserDefaults.lastStoreID] = lastStoreID
                let vm = LoginViewModel()
                expect(vm.storeID.value).to(equal(lastStoreID))
            }
        }
        
        describe("updateState") {
            
            it("should be called when storeID changed") {
                let vm = LoginViewModel()
                let test = RxExpect()
                let storeID = NSUUID().uuidString
                test.retain(vm)
                test.scheduler.scheduleAt(100) {
                    vm.storeID.accept(storeID)
                }
                test.assert(SP.stationManager.status) { events in
//                    expect(events, [Recorded.next(100, storeID)])
                }
            }
        }
        
        describe("store") {
            it("should be updated when shouldRefreshState is published to") {
                let vm = LoginViewModel()
                let test = RxExpect()
                test.retain(vm)
                let storeID = "17021812551554"
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(50, ""),
                        Recorded.next(100, storeID)])
                    .bind(to: vm.storeID)
                test.assert(vm.store) { events in
                    expect(events.count).to(equal(2))
                    expect(events.map { event in event.value.element??.id })
                        .to(equal([nil, storeID]))
                }
            }
        }
        
        describe("station") {
            it("should be updated when storeID changed") {
                let vm = LoginViewModel()
                let test = RxExpect()
                test.retain(vm)
                let storeID = "17021812551554"
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(50, ""),
                        Recorded.next(100, storeID)])
                    .bind(to: vm.storeID)
                test.assert(vm.station) { events in
                    expect(events.count).to(equal(2))
                    expect(events.map { event in event.value.element??.id })
                        .to(equal([nil, "17030212282125"]))
                }
            }
        }
        
        describe("version") {
            it("should display the bundle version") {
                let vm = LoginViewModel()
                expect(vm.version).to(equal("Version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)"))
            }
        }
        
        describe("viewStatus") {
            it("should be none upon loading") {
                let vm = LoginViewModel()
                expect(vm.viewStatus.value).to(equal(ViewStatus.none))
            }
            
//            it("should reflect the status of remote syncing") {
//                fail("not implemented")
//            }
        }
        
        describe("lastUpdated") {
            it("should has the value stored in user default") {
                let lastUpdated = Date()
                Defaults[UserDefaults.lastUpdated] = lastUpdated
                let vm = LoginViewModel()
                let test = RxExpect()
                test.retain(vm)
                test.assert(vm.lastUpdated) { events in
                    XCTAssertEqual(events, [ Recorded.next(0, "Last Updated: \(lastUpdated.toString("MMM d HH:mm"))") ])
                }
            }
        }
    }
}
