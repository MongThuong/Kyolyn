
//
//  File.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/18/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Dip
@testable import Kiolyn

class LoggerGlobalTests: BaseTests {
    override func spec() {
        describe("Logger") {
            it("should invoke the closure") {
                let logger = XCGLoggingService()
                waitUntil { done in
                    let log: () -> Any? = {
                        done()
                        return "log me baby"
                    }
                    logger.info(log())
                }
            }
        }
    }
}


