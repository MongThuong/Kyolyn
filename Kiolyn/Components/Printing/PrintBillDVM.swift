//
//  PrintBillDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AwaitKit

/// The type of bill printing.
///
/// - check: Print as check (for user to review before paying).
/// - receipt: Print as receipt (for user to take away after paying).
enum PrintBillType {
    case check
    case receipt
}

typealias PrintBillDR = (Order, Bill?)

/// For printing Bill either as check or receipt.
class PrintBillDVM: PrintDVM<PrintingJob, PrintBillDR> {
    var bill: Bill? = nil
    var order: Order? = nil
    var transaction: Transaction? = nil
    var type: PrintBillType!
    
    override var allowSkipping: Bool {
        if type == .receipt {
            // printing receipt won't effect the object in anyway, no skipping is needed
            return false
        }
        
        if let _ = transaction {
            // if printing by trans, nothing need to be modified, no skipping is needed
            return false
        }
        
        if let order = order {
            if order.isClosed {
                // if printing by order, and order is closed, no skipping is needed
                return false
            }
            if let bill = bill, bill.paid {
                // if printing by order/bill, and bill is paid, no skipping is needed
                return false
            }
        }
        
        return true
    }

    private init(_ type: PrintBillType) {
        self.type = type
        super.init()
 
        jobs
            .asObservable()
            .subscribe(onNext: { jobs in
                if let job = jobs.first(where: { $0.printer.id == self.defaultPrinter?.id }) {
                    self.print(job: job)
                }
            })
            .disposed(by: disposeBag)
        jobsChanged
            .filter { self.jobs.value.any({ $0.status.value.isOK }) }
            .map { self.dialogResult }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
   }

    convenience init(transaction: Transaction, type: PrintBillType = .check) {
        self.init(type)
        self.transaction = transaction
        self.dialogTitle.accept("Printing \(type == .check ? "Check" : "Receipt") - Trans #\(transaction.transNum)")        
    }

    convenience init(bill: Bill? = nil, of order: Order, type: PrintBillType = .check) {
        self.init(type)
        self.bill = bill
        self.order = order
        var title = "Printing \(type == .check ? "Check" : "Receipt") - Order #\(order.orderNo)"
        if let bill = bill, let billIndex = order.bills.index(of: bill) {
            title = "\(title) / Bill #\(billIndex)"
        }
        self.dialogTitle.accept(title)
    }

    override var dialogResult: PrintBillDR? {
        // Return true if at least one got success
        if let order = order, self.jobs.value.any({ $0.status.value.isOK }) {
            return (order, bill)
        }
        return nil
    }

    override var skipPrintingResult: PrintBillDR? {
        if type == .check, let order = order {
            return (order, bill)
        }
        return nil
    }

    override func createPrintingJobs() throws -> [PrintingJob] {
        let printers: [Printer] = try await(dataService.loadAll())
        return printers
            .filter { printer in printer.isValid }
            .map { printer in PrintingJob(printer) }
    }

    override func doPrint(_ job: PrintingJob) -> Single<Void> {
        do {
            if type == .check {
                // CHECK printing
                if let transaction = transaction {
                    // Load Order/Bill using keys stored inside Transaction
                    guard transaction.order.isNotEmpty, transaction.bill.isNotEmpty,
                        let transOrder: Order = try await(dataService.load(transaction.order)),
                        let transBill: Bill = transOrder.bill(with: transaction.bill) else {
                            return Single.error(PrintError.invalidInputs(detail: "Invalid transaction (missing order/bill info)"))
                    }
                    order = transOrder
                    bill = transBill
                }
                return SP.printingService.print(check: bill, ofOrder: order!, byServer: employee, toPrinter: job.printer)
            } else {
                if transaction == nil {
                    guard let _ = order, let bill = bill,
                        let billTrans: Transaction = try await(dataService.load(bill.transaction)) else {
                            return Single.error(PrintError.invalidInputs(detail: "Invalid order/bill"))
                    }
                    transaction = billTrans
                }
                return SP.printingService.print(receipt: transaction!, byServer: employee, toPrinter: job.printer)
            }
        } catch let error {
            return Single.error(error)
        }
    }
}

