//
//  String+Printing.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/5/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension String {
    /// Convert internal payment type to user friendly payment type.
    ///
    /// - Returns: Printing friendly payment type.
    var formattedPaymentType: String {
        // Empty output for empty input
        guard self.isNotEmpty else { return self }
        // Split by $
        let strs = self.components(separatedBy: "$")
        // Parse the transaction type value
        guard let type = TransactionType(rawValue: strs[0]) else { return self }
        var displayValue: String = ""
        // Add payment type
        switch type {
        case .cash: displayValue += "CASH"
        case .creditSale: displayValue += "CREDIT CARD"
        case .creditVoid: displayValue += "VOID"
        case .creditRefund: displayValue += "REFUND"
        case .creditForce: displayValue += "FORCE"
        case .custom: if strs.count > 2 { displayValue += strs[2] }
        case .batchclose: displayValue += "BATCH"
        }
        // Add sub payment type
        if (type == .custom) {
            if (strs.count > 4) {
                displayValue += " - \(strs[4])"
            }
        }
        else if (strs.count > 2) {
            displayValue += " - \(strs[2])"
        }
        return displayValue
    }
}


