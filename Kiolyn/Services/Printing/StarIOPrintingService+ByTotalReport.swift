//
//  StarIOPrintingService+ByTotalReport.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - Total Report
extension StarIOPrintingService {
    
    func build(totalReportByPaymentTypeTemplate store: Store, fromDate: Date, toDate: Date, shift: Int) throws -> NSAttributedString {
        let data = NSMutableAttributedString(string:"")
        
        data.appendCenterX2("TOTAL REPORT\n")
        data.appendCenter("\(fromDate.toString("MMM d yyyy"))\n\n")
        let shiftsQueryResult = SP.database.load(byPaymentTypeReport: store.id, fromDate: fromDate, toDate: toDate, groupedBy: shift)
        for queryResult in shiftsQueryResult  {
            data.append("------------------------------------------------\n")
            data.appendBold("SHIFT \(queryResult.shift)\n")
            data.append("TYPE        #TRANS       TIP     SALES     TOTAL\n")
            
            // Sort by shift / trans type
            let rows = queryResult.rows
                .sorted { $0.shift > $1.shift }
                .sorted { $0.transType > $1.transType }
            var finalRows: [PaymentTypeTotalReportRow] = []
            var currentRow: PaymentTypeTotalReportRow?
            for r in rows {
                if r.cardType.isEmpty {
                    finalRows.append(r)
                    currentRow = nil
                } else if let row = currentRow {
                    row.total += r.total
                    row.tip += r.tip
                    row.count += r.count
                    finalRows.append(r)
                } else {
                    currentRow = r.clone(without: ["card_type"])
                    finalRows.append(currentRow!)
                    finalRows.append(r)
                }
            }
            
            for r in finalRows {
                if r.cardType.isEmpty {
                    data.append("\(r.transType.formattedPaymentType.exact(11)) \("\(r.count)".padLeft(6)) \(r.tip.asMoney.padLeft(9)) \(r.total.asMoney.padLeft(9)) \(r.totalWithTip.asMoney.padLeft(9))\n")
                } else {
                    data.append("\(r.cardType.uppercased().exact(11)) \("\(r.count)".padLeft(6)) \(r.tip.asMoney.padLeft(9)) \(r.total.asMoney.padLeft(9)) \(r.totalWithTip.asMoney.padLeft(9))\n")
                }
            }
            // TOTAL ROW
            data.append("\n")
            let summary = queryResult.summary
            data.appendBold("\("TOTAL".padRight(11)) \("\(summary.count)".padLeft(6)) \(summary.tip.asMoney.padLeft(9)) \(summary.total.asMoney.padLeft(9)) \(summary.totalWithTip.asMoney.padLeft(9))\n")
        }
        
        return data
    }
    
    func build(totalReportByAreaTemplate store: Store, fromDate: Date, toDate: Date, shift: Int) throws -> NSAttributedString {
        let data = NSMutableAttributedString(string:"")
        
        data.appendCenterX2("TOTAL REPORT\n")
        data.appendCenter("\(fromDate.toString("MMM d yyyy"))\n\n")
        let shiftsQueryResult = SP.database.load(byAreaReport: store.id, fromDate: fromDate, toDate: toDate, groupedBy: shift)
        for queryResult in shiftsQueryResult  {
            data.append("------------------------------------------------\n")
            data.appendBold("SHIFT \(queryResult.shift)\n")
            data.append("AREA        #TRANS       TIP     SALES     TOTAL\n")
            
            // Sort by shift / trans type
            for r in queryResult.rows {
                data.append("\(r.areaName.exact(11)) \("\(r.count)".padLeft(6)) \(r.tip.asMoney.padLeft(9)) \(r.total.asMoney.padLeft(9)) \(r.totalWithTip.asMoney.padLeft(9))\n")
            }
            // TOTAL ROW
            data.append("\n")
            let summary = queryResult.summary
            data.appendBold("\("TOTAL".padRight(11)) \("\(summary.count)".padLeft(6)) \(summary.tip.asMoney.padLeft(9)) \(summary.total.asMoney.padLeft(9)) \(summary.totalWithTip.asMoney.padLeft(9))\n")
        }
        
        return data
    }
}
