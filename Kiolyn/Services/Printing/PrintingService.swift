//
//  PrintingService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/16/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Main interface for printing service.
protocol PrintingService {
    
    /// Open a cash drawer connected to given `Printer`
    ///
    /// - Parameter printer: The connected `Printer`.
    /// - Returns: `Promise` of the opening result.
    func open(cashDrawer printer: Printer) -> Single<Void>
    
    /// Print `OrderItem`s.
    ///
    /// - Parameters:
    ///   - items: The `Item`s to print.
    ///   - order: The `Order` that the orders belong to.
    ///   - server: The server who request the printing.
    ///   - type: The type of printing.
    ///   - printer: The `Printer` to print to
    /// - Returns: `Promise` of the printing result.
    func print(items: [[OrderItem]], ofOrder order: Order, byServer server: Employee, withType type: PrintItemsType, toPrinter printer: Printer) -> Single<Void>
    
    /// Print Check for Order/Bill
    ///
    /// - Parameters:
    ///   - for: The `Bill` to print for
    ///   - order: The `Order` owns the printed `Bill`.
    ///   - server: The `Employee` who request the printing.
    ///   - printer: The `Printer` to print to.
    /// - Returns: `Promise` of the printing result.
    func print(check bill: Bill?, ofOrder order: Order, byServer server: Employee, toPrinter printer: Printer) -> Single<Void>

    /// Print Check for Order/Bill
    ///
    /// - Parameters:
    ///   - printer: The `Printer` to print to.
    ///   - for: The `Bill` to print for
    ///   - order: The `Order` owns the printed `Bill`.
    ///   - server: The `Employee` who request the printing.
    /// - Returns: `Promise` of the printing result.
    func print(receipt transaction: Transaction, byServer server: Employee, toPrinter printer: Printer) -> Single<Void>

    /// Print close batch report.
    ///
    /// - Parameters:
    ///   - printer: The `Printer` to print to.
    ///   - batches: The list of (Device, Closed Transactions, Batch Transaction).
    ///   - store: The `Store` to printer for
    ///   - server: The `Employee` who requests the printing.
    ///   - shift: The `Shift` in which the batch is closed.
    /// - Returns: `Promise` of the printing result.
    func print(closeBatchReport batch: (CCDevice?, [Transaction], Transaction), store: Store, byServer server: Employee, shift: Shift, toPrinter printer: Printer) -> Single<Void>

    /// Print by payment type Total Report.
    ///
    /// - Parameters:
    ///   - store: the `Store`.
    ///   - from: the start date.
    ///   - to: the end date.
    ///   - shift: the shift, 0 = all day.
    ///   - printer: the `Printer`.
    /// - Returns: Promise of printing result.
    func print(totalReportByPaymentType store: Store, fromDate: Date, toDate: Date, shift: Int, toPrinter printer: Printer) -> Single<Void>

    /// Print by area Total Report.
    ///
    /// - Parameters:
    ///   - store: the `Store`.
    ///   - from: the start date.
    ///   - to: the end date.
    ///   - shift: the shift, 0 = all day.
    ///   - printer: the `Printer`.
    /// - Returns: Promise of printing result.
    func print(totalReportByArea store: Store, fromDate: Date, toDate: Date, shift: Int, toPrinter printer: Printer) -> Single<Void>

    /// Print by payment type Report
    ///
    /// - Parameters:
    ///   - printer: the `Printer`.
    ///   - store: the `Store`.
    ///   - from: the start date.
    ///   - to: the end date.
    ///   - shift: the shift, 0 = all day.
    ///   - area: the area, empty = all area
    /// - Returns: Promise of printing result.
    func print(byPaymentTypeReport store: Store, fromDate: Date, toDate: Date, shift: Int, area: String, toPrinter printer: Printer) -> Single<Void>

    /// Print by server report.
    ///
    /// - Parameters:
    ///   - printer: the `Printer`.
    ///   - store: the `Store`.
    ///   - from: the start date.
    ///   - to: the end date.
    ///   - shift: the shift, 0 = all day.
    ///   - server: the server to print, empty is not accepted.
    /// - Returns: Promise of printing result.
    func print(byServerReport store: Store, fromDate: Date, toDate: Date, shift: Int, employee: String, toPrinter printer: Printer) -> Single<Void> 

    /// Print Shift&Day Reprot
    ///
    /// - Parameters:
    ///   - printer: the `Printer`.
    ///   - rows: the rows of data.
    ///   - from: the start date.
    ///   - to: the end date.
    ///   - shift: the shift, 0 = all day.
    /// - Returns: Promise of printing result.
    func print(shiftAndDayReport rows: [NameValueReportRow], byEmployee employee: Employee, fromDate: Date, toDate: Date, shift: Int, toPrinter printer: Printer) -> Single<Void>
}

/// Type of items printing.
///
/// - send: The `Item`s are sent to printer for the first time.
/// - resend: The `Item`s are resent to printer for updating their properties.
/// - void: The `Item`s are voided.
enum PrintItemsType {
    case send
    case resend
    case void
}

/// Type of receipt
///
/// - merchant: For merchant to keep with customer signature as proof of payment agreement.
/// - customer: For customer to take home.
enum PrintReceiptType {
    case merchant
    case customer
}

public enum PrintError: LocalizedError {
    case notEthernetPrinter
    case printerNotFound
    case failedSendingPrintingData
    case printingError(detail: String)
    case invalidInputs(detail: String)
    
    public var errorDescription: String? {
        switch self {
        case .notEthernetPrinter:
            return "Ethernet is the only supported printer type"
        case .printerNotFound:
            return "Printer was not found in local network"
        case .failedSendingPrintingData:
            return "Could not send printing data"
        case .printingError(let detail):
            return detail
        case .invalidInputs(let detail):
            return detail
        }
    }
}
