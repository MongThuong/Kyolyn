//
//  StarIOPrintingService+ByEmployeeReport.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// MARK: - Employee Report
extension StarIOPrintingService {

    func build(byEmployeeSummaryReportTemplate store: Store, fromDate: Date, toDate: Date, shift: Int) throws -> NSAttributedString {
        let data = NSMutableAttributedString(string:"")

        data.appendCenterX2("SERVER REPORT\n")
        data.appendCenter("\(fromDate.toString("MMM d yyyy"))\n\n")

        let shiftsQueryResult = SP.database.load(byEmployeeReport: store.id, fromDate: fromDate, toDate: toDate, groupedBy: shift)
        for queryResult in shiftsQueryResult {
            data.append("------------------------------------------------\n")
            data.appendBold("SHIFT \(queryResult.shift)\n")
            data.append("NAME       OPN CLS       TIP     SALES     TOTAL\n")

            for r in queryResult.rows {
                let opn = "\(r.opening)".padLeft(3)
                let cls = "\(r.closing)".padLeft(3)
                data.append("\(r.name.exact(10)) \(opn) \(cls) \(r.tip.asMoney.padLeft(9)) \(r.total.asMoney.padLeft(9)) \(r.totalWithTip.asMoney.padLeft(9))\n")

            }
            // TOTAL ROW
            let summary = queryResult.summary
            let opn = "\(summary.opening)".padLeft(3)
            let cls = "\(summary.closing)".padLeft(3)
            data.appendBold("\("TOTAL".padRight(10)) \(opn) \(cls) \(summary.tip.asMoney.padLeft(9)) \(summary.total.asMoney.padLeft(9)) \(summary.totalWithTip.asMoney.padLeft(9))\n")
        }
        return data
    }

    func build(byEmployeeDetailReportTemplate store: Store, fromDate: Date, toDate: Date, shift: Int, employee: String) throws -> NSAttributedString {
        let data = NSMutableAttributedString(string:"")
        let db = SP.database
        // Load the employee
        guard let employee: Employee = db.load(employee) else {
            return data
        }

        data.appendCenterX2("SERVER REPORT\n")
        data.appendCenter("\(employee.name.left(35)) - \(fromDate.toString("MMM d yyyy"))\n\n")

        let shiftsQueryResult = db.load(orders: store.id, ofEmployee: employee.id, fromDate: fromDate, toDate: toDate, groupedBy: shift)
        for queryResult in shiftsQueryResult {
            data.append("------------------------------------------------\n")
            data.appendBold("SHIFT \(queryResult.shift) \n")
            data.append("TABLE                   GUESTS#                 \n")
            data.append(" OPENED   CLOSED         TIP     SALES     TOTAL\n")

            for order in queryResult.rows {
                let guests = "\(order.persons)".padLeft(3)
                data.append("\(order.tableName.padRight(24))  \(guests)\n")
                data.append("\(order.openingTime.padRight(8)) \(order.closingTime.padRight(8)) \(order.tip.asMoney.padLeft(9)) \(order.total.asMoney.padLeft(9)) \(order.totalWithTip.asMoney.padLeft(9))\n")
            }

            // TOTAL ROW
            let summary = queryResult.summary
            data.appendBold("\("TOTAL".padRight(17)) \(summary.tip.asMoney.padLeft(9)) \(summary.total.asMoney.padLeft(9)) \(summary.totalWithTip.asMoney.padLeft(9))\n")
        }
        return data
    }
}

