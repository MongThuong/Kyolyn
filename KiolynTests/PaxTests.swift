//
//  PaxRequestTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Quick
import Nimble
@testable import Kiolyn

public class PaxTests: BaseTests {
    override public func spec() {

        let url = "http://192.168.1.22:10009"
        
        describe("Pax Request") {
            
            it("can generate LRC and encode base 64") {
//                // Section 3.3.2.1
//                var input = "A00\u{1c}1.28\u{03}"
//                expect(input.getLRC()) == "K"
//                expect("\u{02}\(input)\(input.getLRC())".base64Encoded()) == "AkEwMBwxLjI4A0s="
//                // Section 3.3.2.2
//                input = "A08\u{1c}1.28\u{1c}0\u{1c}90000\u{03}"
//                expect(input.getLRC()) == "J"
//                expect("\u{02}\(input)\(input.getLRC())".base64Encoded()) == "AkEwOBwxLjI4HDAcOTAwMDADSg=="
//                // Section 3.3.2.3
//                input = "A20\u{1c}1.28\u{1c}0\u{1c}\u{1c}\u{1c}200\u{03}"
//                expect(input.getLRC()) == "K"
//                expect("\u{02}\(input)\(input.getLRC())".base64Encoded()) == "AkEyMBwxLjI4HDAcHBwyMDADSw=="
//                // Section 3.3.2.4
//                input = "T00\u{1c}1.28\u{1c}01\u{1c}100\u{1c}\u{1c}1\u{1c}\u{1c}\u{1c}\u{1c}\u{1c}\u{03}"
//                expect(input.getLRC()) == "C"
//                expect("\u{02}\(input)\(input.getLRC())".base64Encoded()) == "AlQwMBwxLjI4HDAxHDEwMBwcMRwcHBwcA0M="
            }
            
            // Section 5.2.1.3 Example
            it("can build sale request") {
                // 1. First create a request with tender type and trans type
                let request = PaxRequest(URL(string: url)!)
                request.tenderType = .credit
                request.transType = .sale
                // 2. Next Set the PayLink Properties, the only required field is Amount
                request.amount =  String(format: "%g", (1.0 * 100))
                request.ecrRefNum = "1"
                let raw = try! request.buildCommand()
                expect(raw) == "\u{02}T00\u{1C}1.31\u{1C}01\u{1C}100\u{1C}\u{1C}1\u{1C}\u{1C}\u{1C}\u{1C}\u{1C}\u{1C}\u{03}W"
                let requestUrl = try! request.buildRequestUrlString()
                //expect(requestUrl) == "\(url)/?AlQwMBwxLjI4HDAxHDEwMBwcMRwcHBwcA0M=" // Version 1.28 
                expect(requestUrl) == "\(url)/?AlQwMBwxLjMxHDAxHDEwMBwcMRwcHBwcHANX" // Version 1.31
            }
        }
        
        describe("Pax Response") {
            it("can parse credit response") {
                let response = try! PaxResponse(response: "\u{02}0\u{1c}T01\u{1c}1.32\u{1c}000000\u{1c}OK\u{1c}0\u{1f}APPROVED\u{1f}000000\u{1f}88888888\u{1f}\u{1f}\u{1c}01\u{1c}522\u{1f}0\u{1f}22\u{1f}0\u{1f}0\u{1f}33\u{1f}12048\u{1f}2022\u{1c}1111\u{1f}0\u{1f}1122\u{1f}\u{1f}\u{1f}\u{1f}01\u{1f}\u{1f}\u{1f}\u{1f}1\u{1c}1\u{1f}1\u{1f}20170317003101\u{1c}\u{1f}\u{1c}\u{1f}\u{1f}\u{1f}\u{1c}\u{1c}\u{03}`")
//                expect(response.responseCode) == "000000"
//                expect(response.command) == .credit
//                expect(response.transType) == .sale
//
//                expect(response.hostInfo).notTo(beNil())
//                expect(response.hostInfo!.hostCode) == "0"
//                expect(response.hostInfo!.hostMessage) == "APPROVED"
//                expect(response.hostInfo!.hostRefNumber) == "88888888"
//                
//                expect(response.amountInfo).notTo(beNil())
//                expect(response.amountInfo!.amount) == "522"
//                expect(response.amountInfo!.amountDue) == "0"
//                expect(response.amountInfo!.tipAmount) == "22"
//                expect(response.amountInfo!.cashBackAmount) == "0"
//                expect(response.amountInfo!.merchantFee) == "0"
//                expect(response.amountInfo!.taxAmount) == "33"
//                expect(response.amountInfo!.remainingBalance) == "12048"
//                expect(response.amountInfo!.extraBlance) == "2022"
//
//                expect(response.accountInfo).notTo(beNil())
//                expect(response.accountInfo!.accountNumber) == "1111"
//                expect(response.accountInfo!.expireDate) == "1122"
//             
//                expect(response.traceInfo).notTo(beNil())
//                expect(response.traceInfo!.transNumber) == 1
//                expect(response.traceInfo!.ecrRefNum) == "1"
//                expect(response.traceInfo!.timeStamp) == "20170317003101"
            }
        }
    }
}
