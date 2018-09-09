//
//  LoginViewModelSigninTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/23/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//
import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
import RxExpect
import SwiftyUserDefaults
@testable import Kiolyn

public class LoginViewModelSigninTests: BaseTests {
    override public func spec() {
        let db = newCouchbaseTestDatabase()
        
        beforeEach {
            SP.container.register { db as Database }
            Defaults[UserDefaults.lastStoreID] = ""
        }
        
        describe("canSignin") {
            it("should be calculated by store, station, passkey and viewStatus") {
                let vm = LoginViewModel()
                let store: Store? = db.new(model: ["name": "Test Store"])
                let station: Station? = db.new(model: ["name": "Test Station"])
                let test = RxExpect()
                test.retain(vm)
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(50, nil as Store?),
                        Recorded.next(60, store)])
                    .bind(to: vm.store)
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(70, nil as Station?),
                        Recorded.next(80, station)])
                    .bind(to: vm.station)
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(90, ""),
                        Recorded.next(100, "123")])
                    .bind(to: vm.passkey)
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(110, ViewStatus.loading),
                        Recorded.next(120, ViewStatus.error(reason: "")),
                        Recorded.next(130, ViewStatus.ok)])
                    .bind(to: vm.viewStatus)
                test.assert(vm.canSignin) { events in
                    XCTAssertEqual(events, [
                        Recorded.next(0, false),
                        Recorded.next(50, false),
                        Recorded.next(60, false),
                        Recorded.next(70, false),
                        Recorded.next(80, false),
                        Recorded.next(90, false),
                        Recorded.next(100, true),
                        Recorded.next(110, false),
                        Recorded.next(120, true),
                        Recorded.next(130, true)])
                }
            }
        }
        
        describe("signin") {
            it("should show error on fail login attempt") {
                let test = RxExpect()
                let vm = LoginViewModel()
                test.retain(vm)
                
                _ = test.scheduler.createHotObservable([ Recorded.next(50, testStoreID) ]).bind(to: vm.storeID)
                _ = test.scheduler.createHotObservable([ Recorded.next(60, "111") ]).bind(to: vm.passkey)
                test.input(vm.signin, [ Recorded.next(70, ()) ])
                test.assert(vm.viewStatus) { events in
                    XCTAssertEqual(events, [
                        Recorded.next(0, ViewStatus.none),
                        Recorded.next(70, ViewStatus.progress(p: 0.0)),
                        Recorded.next(70, ViewStatus.error(reason: AuthenticationError.invalidPasskey.localizedDescription))])
                }
            }
            
            it("should fire klSignedIn upon success login") {
                let test = RxExpect()
                let vm = LoginViewModel()
                test.retain(vm)
                
                _ = test.scheduler.createHotObservable([ Recorded.next(50, testStoreID) ]).bind(to: vm.storeID)
                _ = test.scheduler.createHotObservable([ Recorded.next(60, "11111") ]).bind(to: vm.passkey)
                test.input(vm.signin, [ Recorded.next(70, ()) ])
                test.assert(vm.viewStatus) { events in
                    XCTAssertEqual(events, [
                        Recorded.next(0, ViewStatus.none),
                        Recorded.next(70, ViewStatus.progress(p: 0.0)),
                        Recorded.next(70, ViewStatus.ok)])
                }
                test.assert(SP.authService.currentIdentity) { events in
                    expect(events.count).to(equal(1))
                }
            }
        }
        
    }
}

