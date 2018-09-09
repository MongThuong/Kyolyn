//
//  DatabaseInitializationTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/14/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

class CouchbaseDatabaseGenericTests: BaseTests {
    override func spec() {
        let db = newCouchbaseTestDatabase()

        describe("save object by its properties") {
            it("should validate inputs") {
                expect { try db.save(properties: [:]) }.to(throwError(DatabaseError.missingMeta(field: "id")))
                expect {
                    try db.save(properties: [
                        "id": "something"])
                    }.to(throwError(DatabaseError.missingMeta(field: "type")))
                expect {
                    try db.save(properties: [
                        "id": "something",
                        "type": "invalidtype"])
                    }.to(throwError(DatabaseError.missingMeta(field: "type")))
                expect {
                    try db.save(properties: [
                        "id": "something",
                        "type": "store"])
                    }.to(throwError(DatabaseError.missingMeta(field: "merchantid")))
                expect {
                    try db.save(properties: [
                        "id": "something",
                        "type": "order",
                        "merchantid": "someid"])
                    }.to(throwError(DatabaseError.missingMeta(field: "channels")))
                expect {
                    try db.save(properties: [
                        "id": "something",
                        "type": "order",
                        "merchantid": "someid",
                        "channels": "somechannel"])
                    }.to(throwError(DatabaseError.missingMeta(field: "channels")))
                expect {
                    try db.save(properties: [
                        "id": "something",
                        "type": "store",
                        "merchantid": "someid",
                        "channels": ["somechannel"]])
                    }.toNot(throwError())
            }
        }

        describe("load properperties using document id") {
            it("should return nil if document does not exists") {
                let prop = db.load(properties: "store_170218125515541")
                expect(prop).to(beNil())
            }
            
            it("should be able to load a document's properties using its document ID") {
                let prop = db.load(properties: "store_\(testStoreID)")
                expect(prop).toNot(beNil())
                expect(prop?.count).to(equal(14))
                expect(prop?["type"] as? String).to(equal("store"))
                expect(prop?["id"] as? String).to(equal(testStoreID))
            }
        }
        
        describe("load model by id") {
            it("should be able to load and return Store") {
                let store: Store? = db.load(testStoreID)
                expect(store).toNot(beNil())
                expect(store?.id).to(equal(testStoreID))
                // TODO: fields checking
            }
            // TODO: all other models
        }
    }
}

