//
//  ServiceProviderTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/14/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Dip
@testable import Kiolyn

class ServiceProviderConfigurationTests: BaseTests {
    override func spec() {
        describe("Service Provider") {
            context("without extra configuration") {
                it("should always have default implementation") {
                    expect(SP.logger).toNot(beNil())
                }
            }
            
            context("having extra configuration") {
                it("should return the configured services") {
                    SP.container = DependencyContainer { container in
                        container.register(.singleton) { MockLoggingService() as LoggingService }
                    }
                    expect(SP.logger).to(beAKindOf(MockLoggingService.self))
                }
            }
        }
    }
}

fileprivate class MockLoggingService: LoggingService { }
