//
//  ByShiftAndDayReportViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Shift&Day Report.
class ByShiftAndDayReportViewModel: TableReportViewModel<NameValueReportRow> {
    override func loadData() -> Single<ReportQueryResult<NameValueReportRow>> {
        let storeID = self.store.id
        let db = SP.database
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value
        return db.async {
            // Get the transactions summary by type for all day or a single shift
            let transactionSummaryByTypeQR = db.load(byPaymentTypeReport: storeID, fromDate: fdate, toDate: tdate, shift: shift, includeCardType: false)
            let transactionsByType = transactionSummaryByTypeQR.rows
            // Make the summary
            let transactionsSummary = transactionSummaryByTypeQR.reportSummary
            // Get the shifts
            let shifts = transactionsSummary.shifts
            // Get the order summary with same input
            let orderSummary = db.load(shiftSummary: storeID, fromDate: fdate, toDate: tdate, shift: shift)
            
            let totalTaxes = orderSummary.tax + orderSummary.serviceFeeTax /* TODO + orderSummary.other_taxes */
            let totalDue = transactionsSummary.total
            let totalServiceFee = orderSummary.serviceFee
            let totalSales = totalDue - totalTaxes - totalServiceFee
            
            // The report row
            var rows: [NameValueReportRow] = []
            rows.add(row: "Total Transactions", value: "\(transactionsSummary.count)")
            rows.add(row: "Total Guests", value: "\(orderSummary.guests)")
            rows.add(row: "Total Sales", value: totalSales.asMoney, type: "superhighlight")
            rows.add(row: "(Total Sales = Total Due - Total Tax - Group Gratuity)", type: "formula")
            rows.add(row: "Total Tax", value: totalTaxes.asMoney, type: "highlight")
            rows.add(row: "Sales Tax", value: orderSummary.tax.asMoney)
            rows.add(row: "Other Tax", value: 0.0.asMoney)
            rows.add(row: "Group Gratuity Tax", value: orderSummary.serviceFeeTax.asMoney)
            rows.add(row: "TOTAL DUE", value: totalDue.asMoney, type: "superhighlight")
            
            // TOTAL CASH IN
            var totalCashIn = transactionsByType.find(.cash, nil, nil)?.total ?? 0
            // Calculate sub cash type also
            totalCashIn += self.settings.cashSubPaymentTypes.reduce(0.0) { (r, pt) in
                r + (transactionsByType.find(.cash, nil, pt)?.total ?? 0)
            }
            rows.add(row: "Total Cash", value: totalCashIn.asMoney, type: "highlight")
            
            // Add row for transaction type
            let addTotalRowForTransType = { (type: TransactionType, customPaymentType: PaymentType? , subPaymentType: PaymentType?) in
                var displayType = ""
                var rowType = "normal";
                switch type {
                case .cash:         displayType = "Cash"
                case .creditSale:   displayType = "Credit Card"
                case .creditVoid:   displayType = "Void"
                case .creditRefund: displayType = "Refund"
                case .creditForce:  displayType = "Force"
                case .custom:       displayType = customPaymentType?.name ?? ""
                default:            displayType = ""
                }
                // Add sub payment type
                if let subPaymentType = subPaymentType {
                    displayType += " - \(subPaymentType.name)";
                    rowType = "sub"
                }
                // Get the transaction info using compound type
                let trans = transactionsByType.find(type, customPaymentType, subPaymentType)
                let total = trans?.total ?? 0
                rows.add(row: displayType, value: total.asMoney, type: rowType)
            }
            // Add CASH line
            addTotalRowForTransType(.cash, nil, nil)
            // Add lines for CASH sub payment types
            for pt in self.settings.cashSubPaymentTypes {
                addTotalRowForTransType(.cash, nil, pt)
            }
            
            // TOTAL Credit
            var totalCredit = transactionsByType.find(.creditSale, nil, nil)?.total ?? 0
            totalCredit += transactionsByType.find(.creditForce, nil, nil)?.total ?? 0
            totalCredit += transactionsByType.find(.creditRefund, nil, nil)?.total ?? 0
            
            // Calculate sub cash type also
            totalCredit += self.settings.cardSubPaymentTypes.reduce(0.0) { (r, pt) in
                r + (transactionsByType.find(.creditSale, nil, pt)?.total ?? 0)
            }
            rows.add(row: "Total Credit", value: totalCredit.asMoney, type: "highlight")
            
            // Add CREDIT CARD line
            addTotalRowForTransType(.creditSale, nil, nil)
            // Add lines for CASH sub payment types
            for pt in self.settings.cardSubPaymentTypes {
                addTotalRowForTransType(.creditSale, nil, pt)
            }
            
            // ADD FORCE line
            addTotalRowForTransType(.creditForce, nil, nil)
            // ADD REFUND line
            addTotalRowForTransType(.creditRefund, nil, nil)
            
            // Add lines for Custom Payment Types
            for pt in self.settings.paymentTypes {
                addTotalRowForTransType(.custom, pt, nil)
                // Add lines for Sub Payment Type
                for spt in pt.subPaymentTypes {
                    addTotalRowForTransType(.custom, pt, spt)
                }
            }
            
            // Voided
            let totalCashOut = orderSummary.serviceFee + transactionsSummary.tip
            rows.add(row: "Cash Out", value: totalCashOut.asMoney, type: "highlight")
            // Group gratuity
            rows.add(row: "Group Gratuity", value: orderSummary.serviceFee.asMoney)
            
            // Add row for transaction type
            // Add row for transaction type
            let addTipRowForTransType = { (type: TransactionType, customPaymentType: PaymentType? , subPaymentType: PaymentType?) in
                var displayType = ""
                switch type {
                case .cash:         displayType = "Cash"
                case .creditSale:   displayType = "Credit Card"
                case .creditVoid:   displayType = "Void"
                case .creditRefund: displayType = "Refund"
                case .creditForce:  displayType = "Force"
                case .custom:       displayType = customPaymentType?.name ?? ""
                default:            displayType = ""
                }
                // Add sub payment type
                if let subPaymentType = subPaymentType {
                    displayType += " - \(subPaymentType.name)";
                }
                // Get the transaction info using compound type
                let trans = transactionsByType.find(type, customPaymentType, subPaymentType)
                let tip = trans?.tip ?? 0
                rows.add(row: "\(displayType) Tip", value: tip.asMoney)
            }
            // Add CASH line
            addTipRowForTransType(.cash, nil, nil)
            // Add lines for CASH sub payment types
            for pt in self.settings.cashSubPaymentTypes {
                addTipRowForTransType(.cash, nil, pt)
            }
            // Add CREDIT CARD line
            addTipRowForTransType(.creditSale, nil, nil)
            // Add lines for CASH sub payment types
            for pt in self.settings.cardSubPaymentTypes {
                addTipRowForTransType(.creditSale, nil, pt)
            }
            // Add lines for Custom Payment Types
            for pt in self.settings.paymentTypes {
                addTipRowForTransType(.custom, pt, nil)
                // Add lines for Sub Payment Type
                for spt in pt.subPaymentTypes {
                    addTipRowForTransType(.custom, pt, spt)
                }
            }
            
            // NET CASH
            let netCash = totalCashIn - totalCashOut;
            rows.add(row: "NET CASH", value: netCash.asMoney, type: "superhighlight")
            rows.add(row: "(Net Cash = Total Cash - Cash Out)", type: "formula")
            // Return query result with rows is total of rows and the selected shifts
            let summary = ReportQuerySummary(count: rows.count)
            summary.shifts = shifts
            return ReportQueryResult<NameValueReportRow>(rows: rows, summary: summary)
        }
    }
    
    override func doPrint(to printer: Printer) -> PrimitiveSequence<SingleTrait, Void> {
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value
        let rows = data.value.rows
        return SP.printingService.print(shiftAndDayReport: rows, byEmployee: employee, fromDate: fdate, toDate: tdate, shift: shift, toPrinter: printer)
    }
}

fileprivate extension Array where Element == NameValueReportRow {
    mutating func add(row name: String, value: String = "", type: String = "normal") {
        append(NameValueReportRow(name: name, value: value, rowType: type))
    }
}

fileprivate extension Array where Element == PaymentTypeTotalReportRow {    
    /// Query transaction based on its type and custom payment type and sub payment type
    ///
    /// - Parameters:
    ///   - type: the transaction type to find.
    ///   - customPaymentType: the custom payment type to find.
    ///   - subPaymentType: the sub payment type to find.
    /// - Returns: the matching row.
    func find(_ type: TransactionType, _ customPaymentType: PaymentType? , _ subPaymentType: PaymentType?) -> PaymentTypeTotalReportRow? {
        var transType = type.rawValue
        if let customPaymentType = customPaymentType {
            transType += "$\(customPaymentType.id)$\(customPaymentType.name)"
        }
        if let subPaymentType = subPaymentType {
            transType += "$\(subPaymentType.id)$\(subPaymentType.name)"
        }
        // Get the transaction info using compound type
        let reportRows = filter { row in row.transType == transType }
        if reportRows.count == 0 {
            return nil
        } else if reportRows.count == 1 {
            return reportRows.first
        } else {
            var tip: Double = 0
            var total: Double = 0
            for t in reportRows {
                tip += t.tip
                total += t.total;
            }
            let row = PaymentTypeTotalReportRow()
            row.tip = tip
            row.total = total
            row.transType = transType
            return row
        }
    }
}
