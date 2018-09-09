//
//  StarIOPrintingService+ByPaymentTypeReport.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - Detail Report
extension StarIOPrintingService {
    func build(byPaymentTypeReportTemplate store: Store, fromDate: Date, toDate: Date, shift: Int, area: String) throws -> NSAttributedString {
        let data = NSMutableAttributedString(string:"")

        data.appendCenterX2("DETAIL REPORT\n")
        data.appendCenter("\(fromDate.toString("MMM d yyyy"))\n\n")

        // Run the query to get data and order result by Shift
        let shiftsQueryResult = SP.database.load(transactions: store.id, fromDate: fromDate, toDate: toDate, area: area, groupedBy: shift)
        for queryResult in shiftsQueryResult {
            // SEPARATOR
            data.append("------------------------------------------------\n")
            // SHIFT
            data.appendBold("SHIFT \(queryResult.shift)\n")
            // HEADER
            data.append(" O#  T# TYPE     NUM       TIP    SALES    TOTAL\n")
            // DATA ROW
            for t in queryResult.rows {
                var type : String = ""
                if t.hasPaymentDevice { type = t.displayCardType }
                else if t.transType == .cash { type = "CASH" }
                else if t.transType == .custom { type = t.customTransTypeName.uppercased() }
                let totalWithTipAmount = t.isVoided ? 0 : t.totalWithTipAmount
                let orderNo = "\(t.orderNum)".padLeft(3)
                let transNo = "\(t.transNum)".padLeft(3)
                data.append("\(orderNo) \(transNo) \(type.exact(8)) \(t.cardNum.exact(4)) \(t.tipAmount.asMoney.padLeft(8)) \(t.approvedAmountByStatus.asMoney.padLeft(8)) \(totalWithTipAmount.asMoney.padLeft(8))\n")
            }
            // TOTAL ROW
            let summary = queryResult.summary
            data.appendBold("\("TOTAL".padRight(21)) \(summary.tip.asMoney.padLeft(8)) \(summary.total.asMoney.padLeft(8)) \(summary.totalWithTip.asMoney.padLeft(8))\n")
        }

        return data
    }
}
