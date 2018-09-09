//
//  ViewStatusTests.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
import RxExpect
import SwiftyUserDefaults
@testable import Kiolyn

public class ViewStatusTests: BaseTests {
    override public func spec() {
        describe("View status") {
            it("should implement Equatable correctly") {
                expect(ViewStatus.none).to(equal(ViewStatus.none))
                expect(ViewStatus.loading).to(equal(ViewStatus.loading))
                expect(ViewStatus.ok).to(equal(ViewStatus.ok))
                
                expect(ViewStatus.none).toNot(equal(ViewStatus.loading))
                expect(ViewStatus.none).toNot(equal(ViewStatus.ok))
                expect(ViewStatus.none).toNot(equal(ViewStatus.error(reason: "")))

                expect(ViewStatus.error(reason: "")).toNot(equal(ViewStatus.none))
                expect(ViewStatus.error(reason: "")).toNot(equal(ViewStatus.error(reason: "1")))
                expect(ViewStatus.error(reason: "1")).to(equal(ViewStatus.error(reason: "1")))
            }
        }
    }
}

