//
//  DatabaseChangedTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/10/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

//public class DatabaseChangedTests: BaseTests {
//    override public func spec() {
//        
//        // Make sure the creation in run on main
//        let db = ServiceProvider.default.database
//        db.peerSyncTest = true
//        
//        describe("Couchbase Database") {
//            
//            self.preload(db, localDbName: "namhoa")
//            
//            // Just to be sure everything is good
//            expect(db.isSetup) == true
//            expect(db.documentCount) > 0
//            
//            it("can notify on data Store changed") {
//                
//                // Assume this is what we got from a call to Sync Session
//                let properties: [String: Any] = [
//                    "type": "store",
//                    "merchantid": "15121510073220",
//                    "id": "12345",
//                    ]
//                let dbChangedNotification = Notification(name: Notification.Name.cblDatabaseChange)
//                let storeChangedNotification = Notification(name: Notification.Name.klPeerSyncStoreChanged, object: db, userInfo: ["id": "12345"])
////                expect {
//                    try! db.save(properties)
////                }.to(postNotifications(equal([dbChangedNotification, storeChangedNotification])))
//            }
//        }
//    }
//}
