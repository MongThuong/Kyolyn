//
//  PreloadTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/10/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

let testStoreID = "17021812551554"

func newTestDbName() -> String {
    return "test-\(UUID().uuidString.lowercased())"
}

func newCouchbaseTestDatabase() -> CouchbaseDatabase {
    let testdb = Bundle(for: BaseTests.self) .path(forResource: "namhoa", ofType: "cblite2")!
    return CouchbaseDatabase(file: testdb, name: newTestDbName())
}

public class BaseTests: QuickSpec {
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
//    func draw()
    override public func spec() {
        describe("add") {
            it("can return add result") {
                expect(self.add(1, 2)).to(equal(3))
                expect(self.add(3, 9)).to(equal(12))
            }
        }
    }
//    func saveTestStore(storeID: String) {
//        // Store is not saved anywhere yet, we need to manually input the Store here for testing purpose, in login screen, the Sync must do this work instead. Assume this is what we got from a call to Sync Session.
//        let properties: [String: Any] = [
//            "type": "store",
//            "merchantid": "15121510073220",
//            "id": storeID,
//            "biz_country": "Vietnam",
//            "store_name": "Nam Hòa",
//            "biz_city": "HCM",
//            "biz_state": "Ho Chi Minh",
//            "biz_phone": "0909117758",
//            "biz_address": "Somewhere in Saigon",
//            "biz_zip": "70000",
//            "merchant_id": "12345",
//            "terminal_id": "890",
//            "sync_session": [
//                "cookie_name": "SyncGatewaySession",
//                "session_id": "aca85f9fabe9c6977b34c25fecaa9e789f73318b",
//                "expires": SyncSession.expiresFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
//            ]
//        ]
//        try! self.database.save(properties)
//    }
}
