//
//  CCServiceTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/13/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

import Quick
import Nimble
import PromiseKit
@testable import Kiolyn

public class CCServiceTests: BaseTests {
    override public func spec() {
        
        // For keeping the scanner alive after leaving the block
        // Loop back address, need to change to the machine that run this test.
        let scanner = NetworkUtil.MacAddressScanner("60:f8:1d:d1:0b:86")
        
        beforeSuite {
            self.preload(localDbName: "namhoa")
        }
        
        describe("Network Util") {
            
            it("can scan network for a mac address") {
                
                waitUntil(timeout: 1000) { done in
                    firstly {
                        scanner.start()
                    }.then { ipAddress -> Void in
                        expect(ipAddress).notTo(beEmpty())
                        done()
                    }.catch { error in
                        fail("Failed scanning")
                        done()
                    }
                    
                }
            }
        }
    }
}
