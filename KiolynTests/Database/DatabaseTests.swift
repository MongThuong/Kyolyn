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

class DatabaseInitializationTests: BaseTests {
    override func spec() {
        describe("Database") {
            it("should be initialzed correctly from service provider") {
                expect(SP.database).toNot(beNil())
            }
        }
    }
}
