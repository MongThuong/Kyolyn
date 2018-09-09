//
//  CouchbaseAuthenticationTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxTest
import RxExpect
import Dip
import RxSwift
@testable import Kiolyn

class CouchbaseAuthenticationTests: BaseTests {
    override func spec() {
        let db = newCouchbaseTestDatabase()
        let auth = CouchbaseAuthenticationService()
        guard let store: Store = db.load(testStoreID),
            let station = db.load(station: store.id, byMacAddress: "705a0f1792e5") else {
                fail("Could not load test Store and Station")
                return
        }
        
        beforeEach {
            SP.container.register { db as Database }
        }

        describe("signin") {
            it("should deny blank passkey") {
                let test = RxExpect()
                test.assert(auth.signin(store, station: station, withPasskey: "")) { events in
                    expect(events.error as? AuthenticationError).to(equal(AuthenticationError.invalidPasskey))
                }
            }
            it("should deny invalid passkey") {
                let test = RxExpect()
                test.assert(auth.signin(store, station: station, withPasskey: "111")) { events in
                    expect(events.error as? AuthenticationError).to(equal(AuthenticationError.invalidPasskey))
                }
            }
            it("should deny employee without order permission") {
                let test = RxExpect()
                test.assert(auth.signin(store, station: station, withPasskey: "1111")) { events in
                    expect(events.error as? AuthenticationError).to(equal(AuthenticationError.lackOrderPermission))
                }
            }
            it("should accept user with order permission") {
                let test = RxExpect()
                test.assert(auth.signin(store, station: station, withPasskey: "11111")) { events in
                    expect(events.error).to(beNil())
                }
            }
        }
        
        describe("singout") {
            it("should clear the identity") {
                waitUntil { done in
                    _ = auth.signin(store, station: station, withPasskey: "11111")
                        .subscribe(onSuccess: { _ in
                            expect(auth.currentIdentity.value).toNot(beNil())
                            auth.signout()
                            expect(auth.currentIdentity.value).to(beNil())
                            done()
                        })
                }
            }
            it("should fire .klSignedOut event") {
                let test = RxExpect()
                test.scheduler.scheduleAt(50) {
                    _ = auth.signin(store, station: station, withPasskey: "11111")
                        .subscribe(onSuccess: { _ in })
                }
                test.scheduler.scheduleAt(60) {
                    auth.signout()
                }
                test.assert(SP.authService.currentIdentity) { events in
                    expect(events.count).to(equal(1))
                }
            }
        }
    }    
}
