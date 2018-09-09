//
//  CouchbaseDatabaseLoadModelTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

import Quick
import Nimble
import ObjectMapper
@testable import Kiolyn

class CouchbaseDatabaseLoadModelTests: BaseTests {
    override func spec() {
        let db = newCouchbaseTestDatabase()

        describe("loading model") {
            it("should be able to load Settings") {
                let settings: Settings? = db.load(testStoreID)
                expect(settings).toNot(beNil())
                expect(settings?.channels).toNot(beEmpty())
                expect(settings?.categoryTypes).to(equal(["BEVERAGE"]))
            }
            it("should be able to load all Areas") {
                let areas: [Area] = db.load(all: testStoreID)
                expect(areas.count) == 4
            }
            it("should be able to load Settings as Mappable") {
                let store: MappableStore = db.load(testStoreID)!
                expect(store.type).to(equal("store"))
            }
        }
    }
}
