//
//  CouchbaseDatabaseStationTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/21/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

class CouchbaseDatabaseStationTests: BaseTests {
    override func spec() {
        describe("load station by mac") {
            let testdb = Bundle(for: BaseTests.self).path(forResource: "namhoa", ofType: "cblite2")!
            let db = CouchbaseDatabase(file: testdb, name: newTestDbName())

            it("should return main station if mac is a passthrough") {
                let mainStation = db.load(station: testStoreID, byMacAddress: "705a0f1792e5")
                expect(mainStation).toNot(beNil())
                expect(mainStation!.main).to(beTrue())
            }
            
            it("should return right station by mac address") {
                let nilStation = db.load(station: testStoreID, byMacAddress: "invalid")
                expect(nilStation).to(beNil())
                let station = db.load(station: testStoreID, byMacAddress: "9cb70d793fb8")
                expect(station).toNot(beNil())
                expect(station!.id).to(equal("17030212282125"))
            }
        }
    }
}
