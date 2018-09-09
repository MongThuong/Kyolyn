//
//  ConfigurationTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/14/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

class ConfigurationTests: BaseTests {
    override func spec() {
        describe("Configuration") {
            it("should return staging environment") {
                expect(Kiolyn.Configuration.apiRootURL).to(equal("http://kiolyn-api.willbe.vn"))
            }
        }
    }
}
