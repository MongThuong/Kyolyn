//
//  StarIOPrintingService+CloseBatch.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation


// MARK: - Transaction related
extension StarIOPrintingService {
    
    func build(closeBatchReportTemplate batch: (CCDevice?, [Transaction], Transaction), store: Store, byServer server: Employee, shift: Shift) throws -> NSAttributedString {
        let data = NSMutableAttributedString(string:"")
        
        data.appendCenterX2("\(store.storeName)\n")
        data.appendCenter("\(store.bizAddress)\n")
        data.appendCenter("\(store.bizCity), \(store.bizState) \(store.bizZip)\n")
        data.appendCenter("\(store.bizPhone)\n")
        data.append("\n")
        
        data.append("\(Date().toString("MM/dd/yyyy"))\n")
        data.append("Shift: \(shift.index)\n")
        data.append("Server: \(server.name)\n")
        data.append("\n")
        
        data.appendBoldCenterX2("BATCH REPORT")
        data.append("\n\n")
        
        data.append("------------------------------------------------\n")
        
        let (device, closedTranses, closingTrans) = batch
                
        if let device = device {
            data.appendX2("\(device.name)\n")
            data.append("Batch Number: \(closingTrans.batchNum)\n")
            data.append("Credit Amt.:                        \(closingTrans.creditAmount.asMoney.padLeft(12))\n")
        } else {
            data.appendX2("CASH\n")
        }
        
        var saleCount = 0, refundCount = 0
        var baseAmount: Double = 0.0, tipAmount = 0.0, refundAmount = 0.0
        for trans in closedTranses {
            if trans.transType == .creditRefund {
                refundCount += 1
                refundAmount += trans.approvedAmount
            } else {
                saleCount += 1
                baseAmount += trans.approvedAmount
                tipAmount += trans.tipAmount
            }
        }
        data.append("\n")
        data.append("Sales:   \(String(saleCount).padLeft(3))\n")
        data.append("    Base:                           \(baseAmount.format("%.2f").padLeft(12))\n")
        data.append("    Tip:                            \(tipAmount.format("%.2f").padLeft(12))\n")
        data.append("    Total:                          \((baseAmount + tipAmount).format("%.2f").padLeft(12))\n")
        data.append("Refunds: \(String(refundCount).padLeft(3))                        \(refundAmount.format("%.2f").padLeft(12))\n")
        data.append("Net Total:                          \((baseAmount + tipAmount - refundAmount).format("%.2f").padLeft(12))\n")
        data.append("------------------------------------------------\n")

        return data
    }
}

