//
//  PrintItemsDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/5/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AwaitKit

/// Printing job specific to printing items to kitchen.
class ItemsPrintingJob: PrintingJob {
    var items: [[OrderItem]]?
}

// MARK: - The type of printing items.
fileprivate extension PrintItemsType {
    func dialogTitle(for order: Order) -> String {
        switch self {
        case .send:
            return "Submit Items (#\(order.orderNo))"
        case .resend:
            return "Resend Items (#\(order.orderNo))"
        case .void:
            return "Delete Items (#\(order.orderNo))"
        }
    }
}

/// The result of printing items.
typealias PrintItemsDR = (Order, [OrderItem])

/// The printing items view model.
class PrintItemsDVM: PrintDVM<ItemsPrintingJob, PrintItemsDR> {

    var order: Order!
    var orderItems: [OrderItem]!
    var type: PrintItemsType!

    /// For printing items to printer.
    ///
    /// - Parameters:
    ///   - order: The `Order` to print.
    ///   - items: The `OrderItem`s to print.
    ///   - type: The type of printing.
    init(_ order: Order, orderItems: [OrderItem], type: PrintItemsType = .send) {
        self.order = order
        self.orderItems = orderItems
        self.type = type

        super.init()
        // Result is default to empty
        dialogTitle.accept(type.dialogTitle(for: order))

        // Start printing every jobs upon created, this is because
        // items are distributed to different printers, thus every single jobs
        // did different works
        jobs.asDriver()
            .drive(onNext: { jobs in
                for job in jobs {
                    self.print(job: job)
                }
            })
            .disposed(by: disposeBag)

        jobsChanged
            .filter { self.jobs.value.all({ job in job.status.value.isOK }) }
            .map { _ -> PrintItemsDR? in (order, orderItems) }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }

    /// Return the printed items
    override var dialogResult: PrintItemsDR? {
        guard let order = order else { return nil }

        let printedItems = jobs.value.flatMap({ job -> [OrderItem] in
            guard job.status.value.isOK, let items = job.items else {
                return []
            }
            return items.flatMap { $0 }
        })

        return (order, printedItems.unique())
    }

    /// Assume all order items were printed.
    ///
    /// - Returns: The print items result.
    override var skipPrintingResult: PrintItemsDR? {
        return (order, orderItems)
    }

    override func doPrint(_ job: ItemsPrintingJob) -> Single<Void> {
        guard let items = job.items, items.isNotEmpty else {
            return Single.just(())
        }
        if job.printer.printerModel.isLabelPrinter {
            return SP.labelPrintingService.print(items: items, ofOrder: order, withType: type, toPrinter: job.printer)
        } else {
            return SP.printingService.print(items: items, ofOrder: order, byServer: employee, withType: type,  toPrinter: job.printer)
        }
    }

    override func createPrintingJobs() throws -> [ItemsPrintingJob] {
        guard let order = self.order else {
            return []
        }
        d("PRINTING ITEMS OF #\(order.orderNo)")
        // Load the items that are in the order item list
        let items: [Item] = try await(dataService.load(multi: orderItems
            .filter { $0.isNotOpenItem }
            .map { $0.itemID }
            .unique()
        ))
        // Load all categories
        let categories: [Category] = try await(dataService.load(multi:
            items.map { $0.category }.unique()
        ))
        // Load all printers
        let printers: [Printer] = try await(dataService.loadAll()).filter { $0.isValid }
        d("LIST OF PRINTERS \(printers.map{"[\($0.id)] \($0)"}.joined(separator: ", "))")
        // Map items to its printer
        var jobs: [ItemsPrintingJob] = []
        // Get the def printer, use no printer if there is no def printer could be identified
        let defPrinter = self.defaultPrinter ?? Printer.noPrinter

        // Add a single item to a printing job of the given printer
        func add(orderItem: OrderItem, to printer: Printer) {
            d("ADDING ORDERITEM \(orderItem) TO PRINTER \(printer)")
            // Find the job that print to same printer
            if let existingJob = jobs.first(where: { $0.printer.id == printer.id }) {
                // There is an existing job of the same printer, we need to allocate the order item to the correct printing items list
                var added = false
                for (i, its) in existingJob.items!.enumerated() {
                    // If it is already added to this list - skip
                    if its.contains(where: { $0.id == orderItem.id }) {
                        continue
                    }
                    // Add it to a current list
                    existingJob.items![i].append(orderItem)
                    added = true
                    break
                }
                // Create a new list if needed
                if !added {
                    existingJob.items?.append([orderItem])
                }
            } else {
                // Not found - good! create a new printer job
                let job = ItemsPrintingJob(printer)
                job.items = [[orderItem]]
                jobs.append(job)
            }
        }

        // 3 options here
        // 1. use the item printers (either ones selected as in open item dialog or ones selected in web portal)
        // 2. use category printers
        // 3. use default printer
        for orderItem in orderItems {
            d("ALLOCATING ORDER ITEM \(orderItem)")
            // True if this order item can be bound to item printers
            var hasItemPrinter = false
            var itemPrinters: [BaseModel] = []
            if orderItem.isOpenItem {
                itemPrinters.append(contentsOf: orderItem.printers)
            } else {
                // Otherwise, find the item correspond to this order item
                // Scenarios
                // 1. Item is added to Order which is in the Submitted status (everything got saved)
                // 2. Item is not yet sent
                // 3. Item got removed from the system
                // => just ignore it
                if let item: Item = items.first(where: { $0.id == orderItem.itemID }) {
                    itemPrinters.append(contentsOf: item.printers)
                }
            }
            d("ITEM PRINTERS \(itemPrinters.map{ "\($0)" }.joined(separator: ", "))")
            // If there is no printer defined for item, use its category printer
            // if there is no category printer either, use the default printer
            for printerRef in itemPrinters {
                guard let printer = printers.first(where: { $0.id == printerRef.id }) else { continue }
                add(orderItem: orderItem, to: printer)
                hasItemPrinter = true
            }
            // Just skip if we already have item printers
            if hasItemPrinter { continue }

            var hasCategoryPrinter = false
            // Find category of order item
            if let category = categories.first(where: { $0.id == orderItem.categoryID }) {
                d("CATEGORY PRINTERS \(category.printers.map{ "\($0)" }.joined(separator: ", "))")
                for printerRef in category.printers {
                    guard let printer = printers.first(where: { $0.id == printerRef.id }) else { continue }
                    add(orderItem: orderItem, to: printer)
                    hasCategoryPrinter = true
                }
            }
            // If we got a category printer, the move on
            if hasCategoryPrinter { continue }

            // Last resort, no printer can be identified, add to def printer
            add(orderItem: orderItem, to: defPrinter)
        }
        
        return jobs
    }
}


