//
//  NonCardBatchResult.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For closing batch of non-card transactions.
class NonCardBatchResult: BatchResult {
    var displayCode: String { return ""}
    var displayMessage: String { return ""}
    var isApproved: Bool { return true }
    var hostCode: String? { return nil }
    var authCode: String? { return nil }
    var batchNum: String? { return nil }
    var hostTraceNum: String? { return nil }
    var mid: String? { return nil }
    var tid: String? { return nil }
    var timestamp: String? { return nil }
    var totalAmount: Double = 0.0
    var totalCount: Int = 0
    var hostResponse: String? { return nil }
    var message: String? { return nil }
    var extData: String? { return nil }
    var resultCode: String { return "" }
    var resultTxt: String { return "" }
    init(transactions: [Transaction]) {
        totalCount = transactions.count
        totalAmount = transactions.reduce(0.0, { (r, t) in r + t.approvedAmountByStatus })
    }
}
