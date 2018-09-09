//
//  StarIOPrintingService+ByShiftAndDayReport.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

//// MARK: - Shift&Day&Cash Report
extension StarIOPrintingService {

    func build(shiftAndDayReportTemplate rows: [NameValueReportRow], byEmployee employee: Employee, fromDate: Date, toDate: Date, shift: Int) throws -> NSAttributedString {
        let data = NSMutableAttributedString(string:"")

        data.appendCenterX2("SHIFT & DAY REPORT\n")
        data.appendCenter("\(employee.name)\n")
        data.appendCenter("From date \(fromDate.toString("MMM d yyyy"))\n")
        data.appendCenter("To date \(toDate.toString("MMM d yyyy"))\n")
        data.append("\n")
        data.append("------------------------------------------------\n")

        for row in rows {
            if (row.rowType == "highlight") {
                data.appendCenterX2("\n\(row.name.exact(13)) \(row.value.padLeft(10))\n")
            } else if (row.rowType == "superhighlight") {
                data.appendBoldX2("\n\(row.name.exact(13)) \(row.value.padLeft(10))\n")
            } else {
                data.append("\(row.name.padRight(35, char: ".")) \(row.value.padLeft(12))\n")
            }
        }
        return data
    }
}


