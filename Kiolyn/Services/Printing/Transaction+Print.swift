//
//  Transaction+Print.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/5/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension Transaction {
    /// For displaying on Receipt
    var printingTransType: String {
        if isVoided { return "VOIDED" }
        // Add payment type
        switch transType {
        case .cash: return "CASH"
        case .creditSale: return "CREDIT SALE"
        case .creditVoid: return "VOID"
        case .creditRefund: return "REFUND"
        case .creditForce: return "FORCE"
        case .custom: return customTransTypeName.uppercased()
        case .batchclose: return "BATCH CLOSE"
        }
    }
}

