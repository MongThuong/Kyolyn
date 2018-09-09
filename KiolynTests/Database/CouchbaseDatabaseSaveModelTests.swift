//
//  CouchbaseDatabaseSaveModelTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 5/14/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

class CouchbaseDatabaseSaveModelTests: BaseTests {
    override func spec() {
        let db = newCouchbaseTestDatabase()
        
        describe("saving model") {
            it("should save store correctly") {
                let store: MappableStore = db.load(testStoreID)!
                expect(store.storeName).to(equal("Nam Hòa"))
                store.storeName = "A new name"
                try! db.save(store)
                let store1: MappableStore = db.load(testStoreID)!
                expect(store1.storeName).to(equal("A new name"))
            }
        }
    }
}
