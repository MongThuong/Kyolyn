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

public class LoginViewModelRemoteSyncTests: BaseTests {
    override public func spec() {
        describe("remoteSync") {
            it("should call update state when finished") {
//                let vm = LoginViewModel()
//                let test = RxExpect()
//                test.retain(vm)
//                vm.storeID.accept(testStoreID)
//                vm.passkey.accept("111")
//                test.input(vm.remoteSync, [Recorded.next(100, ())])
//                test.assert(vm.lastUpdated) { events in
//
//                }
            }
        }
        
        describe("canRemoteSync") {
            it("should be calculated by storeID, passkey and viewStatus") {
                let vm = LoginViewModel()
                let test = RxExpect()
                test.retain(vm)
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(50, ""),
                        Recorded.next(51, ""),
                        Recorded.next(100, "123456789101112")])
                    .bind(to: vm.storeID)
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(200, ViewStatus.loading),
                        Recorded.next(201, ViewStatus.loading),
                        Recorded.next(210, ViewStatus.error(reason: "")),
                        Recorded.next(220, ViewStatus.ok)])
                    .bind(to: vm.viewStatus)
                _ = test.scheduler
                    .createHotObservable([
                        Recorded.next(300, ""),
                        Recorded.next(301, ""),
                        Recorded.next(310, "123")])
                    .bind(to: vm.passkey)
                test.assert(vm.canRemoteSync) { events in
                    XCTAssertEqual(events, [
                        Recorded.next(0, false),
                        Recorded.next(100, false),
                        Recorded.next(200, false),
                        Recorded.next(210, false),
                        Recorded.next(220, false),
                        Recorded.next(310, true)])
                }
            }
        }
    }
}

