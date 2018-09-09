//
//  CouchbaseDatabaseRemoteSyncTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxExpect
@testable import Kiolyn

class CouchbaseDatabaseRemoteSyncTests: BaseTests {
    // To hold the testing until the sync is completed
    let syncCompletedSemaphore = DispatchSemaphore(value: 0)
    let dispatchQueue = DispatchQueue(label: "com.prit.kiolyn.DispatchQueue", attributes: .concurrent)
    
    override public func spec() {
        
        let storeID = "17082212245480"
        let passkey = "111" // Can take order
        let mac = "705a0f1792e5" // Passthrough MAC
        //let expectedDocumentCount: UInt = 34

        describe("CouchbaseDatabase Remote Sync") {
            it("can download database using remote sync") {
                let testdb = Bundle(for: BaseTests.self) .path(forResource: "empty", ofType: "cblite2")!
                let db = CouchbaseDatabase(file: testdb,name: newTestDbName())

                // Make sure db is empty
                expect(db.documentCount).to(equal(0))
                
                waitUntil(timeout: 10) { done in
                    _ = db.sync(remote: storeID, passkey: passkey, mac: mac)
                        .subscribe { event in
                            switch event {
                            case let .error(error):
                                fail(error.localizedDescription)
                                done()
                            case .completed:
                                expect(db.documentCount) > 1
                                let store: Store? = db.load(storeID)
                                expect(store).toNot(beNil())
                                done()
                            case let .next(progress):
                                expect(progress) >= 0.0
                                expect(progress) <= 1.0
                            }
                    }
                }
            }
        }
    }
}
