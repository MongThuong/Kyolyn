//
//  DataServiceTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/3/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import Kiolyn

public class DataServiceTests: BaseTests {
    override public func spec() {
        
        let storeID = "17021812551554" // Nam Hoa
        
        beforeSuite {
            self.preload(localDbName: "namhoa")
            self.saveTestStore(storeID: storeID)
        }
        
        describe("Shift Service") {
            
            context("running on sub station") {
                
            }
            
            context("running on main station") {
                
                beforeSuite {
                    _ = try! self.authService.signin(storeID, passkey: "11111", mac: "9CB70D793fb8")
                }
                
                it("should have no active shift by default") {
                    expect(self.dataService.activeShift).to(beNil())
                }
                
                it("can open a new shift") {
                    waitUntil(action: { (done) in
                        self.dataService.openNewShift()
                            .then(execute: { _ -> Void in
                                expect(self.dataService.activeShift).toNot(beNil())
                                expect(self.dataService.activeShift?.index) == 2
                                expect(self.dataService.activeShift?.transNum) == 1
                                expect(self.dataService.activeShift?.orderNum) == 1
                                done()
                            })
                            .catch(execute: { (error) in
                                fail(error.localizedDescription)
                                done()
                            })
                    })
                }
                
                it("can increase counter") {
                    waitUntil(action: { (done) in
                        self.dataService.increase(counter: .orderNo)
                            .then(execute: { _ -> Void in
                                expect(self.dataService.activeShift).toNot(beNil())
                                expect(self.dataService.activeShift?.orderNum) == 2
                                done()
                            })
                            .catch(execute: { (error) in
                                fail(error.localizedDescription)
                                done()
                            })
                    })
                    waitUntil(action: { (done) in
                        self.dataService.increase(counter: .transNo)
                            .then(execute: { _ -> Void in
                                expect(self.dataService.activeShift).toNot(beNil())
                                expect(self.dataService.activeShift?.transNum) == 2
                                done()
                            })
                            .catch(execute: { (error) in
                                fail(error.localizedDescription)
                                done()
                            })
                    })
                }
                
                it ("can close an active shift") {
                    waitUntil(action: { (done) in
                        self.dataService.closeActiveShift(moveOpeningTableToNextShift: false)
                            .then(execute: { _ -> Void in
                                expect(self.dataService.activeShift).to(beNil())
                                done()
                            })
                            .catch(execute: { (error) in
                                fail(error.localizedDescription)
                                done()
                            })
                    })
                }
            }
            
        }
    }
}
