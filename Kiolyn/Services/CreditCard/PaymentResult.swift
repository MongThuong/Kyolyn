//
//  PaymentResult.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

protocol PaymentResult: CCResult {    
    var avsResponse: String? { get }
    var bogusAccountNum: String? { get }
    var cardType: String? { get }
    var cvResponse: String? { get }
    var hostResponse: String? { get }
    var approvedAmount: Double { get }
    var refNum: String? { get }
    var remainingBalance: Double { get }
    var extraBalance: Double { get }
    var requestedAmount: Double { get }
    var timestamp: String? { get }
    var rawResponse: String? { get }
}
