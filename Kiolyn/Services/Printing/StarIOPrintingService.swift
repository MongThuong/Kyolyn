//
//  StarIOPrintingService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import AwaitKit

fileprivate extension Printer {
    var portName: String { return "TCP:\(self.ipAddress)" }
    var portSettings: String { return "" }
    var modelName: String { return "TSP143 (STR_T-001)" }
}

/// Paper size of printing
enum PrintPaperSize: Int {
    case twoInches = 384
    case threeInches = 576
    case fourInches = 832
    case escPosThreeInches = 512
    case dotImpactThreeInches = 210
    
    var fvalue: CGFloat {
        return CGFloat(self.rawValue)
    }
}

/// StarIO implementation of the printing services.
class StarIOPrintingService {
    
    fileprivate let queue = DispatchQueue(label: "com.kiolyn.printing", attributes: .concurrent)
    
    /// Find a printer IP address
    ///
    /// - Parameter printer: The Printer to find.
    /// - Returns: The found IP address.
    func findIP(printer: Printer) -> String? {
        // Add list printer to array
        guard let foundPorts = SMPort.searchPrinter("TCP:") as? [PortInfo],
            foundPorts.isNotEmpty else {
                return nil
        }
        return foundPorts
            .first { port -> Bool in
                // Must contain all the necessary info
                guard let _ = port.modelName, let macAddress = port.macAddress, let _ = port.portName else { return false }
                // Must match the one we are looking for
                return macAddress.replacingOccurrences(of: ":", with: "").lowercased() == printer.macAddress.lowercased()
            }
            .map { $0.portName!.right(from: 4) }
    }
    
    /// Send builder to printer.
    ///
    /// - Parameters:
    ///   - printer: The `Printer` to perform the printing on
    ///   - builder: The Builder to send.
    /// - Returns: `true` if sending OK, false otherwise
    private func send(to printer: Printer, data: NSData) -> Bool {
        guard !Configuration.testPrinting else { return true }
        // Send to printer
        return StarCommunication.sendCommands(commands: data, portName: printer.portName, portSettings: printer.portSettings, timeout: 10000) { (succeed, title, message) in }
    }
    
    /// Send text content to printing.
    ///
    /// - Parameters:
    ///   - printer: The `Printer` to perform the printing on
    ///   - generate: The printing text generator.
    /// - Returns: A `Promise` about the printing result.
    func send(to printer: Printer, data generate: @escaping (DataService) throws -> NSAttributedString) -> Single<Void> {
        return self.send(to: printer) { (db, builder) in
            builder.append(bitmap: try generate(db))
            builder.appendPaperCut()
            builder.appendBuzz()
        }
    }
    
    /// Send data in string format to printer for printing.
    ///
    /// - Parameters:
    ///   - printer: The `Printer` to perform the printing on
    ///   - generate: The printing data generator.
    /// - Returns: A `Promise` about the printing result.
    func send(to printer: Printer, data generate: @escaping (DataService, ISCBBuilder) throws -> Void) -> Single<Void> {
        // Make sure printer is online
        guard Configuration.testPrinting || printer.printerType == .ethernet else {
            return Single.error(PrintError.notEthernetPrinter)
        }
        return queue.ak.async {
            let ds = SP.dataService
            // Find printers and update its IP address
            if !Configuration.testPrinting && printer.noIPAddress {
                guard let ip = self.findIP(printer: printer), ip.isNotEmpty else {
                    throw PrintError.printerNotFound
                }
                printer.ipAddress = ip
                _ = try await(ds.save(printer))
            }
            
            #if DEBUG
            let dstPath = NSTemporaryDirectory()
            let files = try FileManager.default.contentsOfDirectory(atPath: dstPath)
            for fileName in files {
                if fileName.hasPrefix("thermal_") {
                    try FileManager.default.removeItem(atPath: "\(dstPath)/\(fileName)")
                }
            }
            #endif
            
            // Build content
            let modelIndex = StarModelCapability.modelIndexAtModelName(modelName: printer.modelName)
            let emulation = StarModelCapability.emulationAtModelIndex(modelIndex: modelIndex)
            let builder: ISCBBuilder = StarIoExt.createCommandBuilder(emulation)
            builder.beginDocument()
            try generate(ds, builder)
            builder.endDocument()
            let data: NSData = builder.commands.copy() as! NSData
            
            // It will success most of the case
            if self.send(to: printer, data: data) {
                return
            }
            
            // IP might changed, so try to find the printer again
            // if the printer is found with same IP, something is wrong
            guard let ip = self.findIP(printer: printer), ip.isNotEmpty else {
                throw PrintError.printerNotFound
            }
            // IP is found and the same as before, so it's some different error
            guard ip != printer.ipAddress else {
                throw PrintError.failedSendingPrintingData
            }
            // Looks like IP has changed, we save the new IP
            printer.ipAddress = ip
            _ = try await(ds.save(printer))
            // ... then resend
            if self.send(to: printer, data: data) {
                return
            } else {
                throw PrintError.failedSendingPrintingData
            }            
        }
    }
}

extension StarIOPrintingService: PrintingService {
    
    func open(cashDrawer printer: Printer) -> Single<Void> {
        return send(to: printer) { (db, builder) in
            builder.appendPeripheral(.no1)
        }
    }
    
    func print(items: [[OrderItem]], ofOrder order: Order, byServer server: Employee, withType type: PrintItemsType, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { (ds, builder) in
            for its in items {
                builder.append(bitmap: try self.build(itemsTemplate: its, ofOrder: order, byServer: server, withType: type, using: ds))
                builder.appendPaperCut()
            }
            builder.appendBuzz()
        }
    }
    
    /// If bill is given, send that bill alone, otherwise send ALL the bill found in Order.
    func print(check bill: Bill?, ofOrder order: Order, byServer server: Employee, toPrinter printer: Printer) -> Single<Void> {
        if let bill = bill {
            return send(to: printer) { ds in
                try self.build(checkTemplate: bill, ofOrder: order, byServer: server, using: ds)
            }
        } else {
            return send(to: printer) { (ds, builder) in
                for bill in order.bills {
                    builder.append(bitmap: try self.build(checkTemplate: bill, ofOrder: order, byServer: server, using: ds))
                    builder.appendPaperCut()
                }
                builder.appendBuzz()
            }
        }
    }
    
    /// Send 2 different versions (Merchant/Customer) of the Receipt.
    func print(receipt transaction: Transaction, byServer server: Employee, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { (ds, builder) in
            // Load Store
            guard let store: Store = try await(ds.load(transaction.storeID)) else {
                    throw PrintError.invalidInputs(detail: "Could not load Store or Settings.")
            }
            // Load print settings (or just use a default one if not exist)
            let settings: CCReceiptPrintingSettings = try await(ds.load(store.id)) ?? CCReceiptPrintingSettings()
            // Load order if any
            var order: Order? = nil
            if (transaction.transType == .creditSale || transaction.transType == .cash || transaction.transType == .custom) && transaction.order.isNotEmpty {
                order = try await(ds.load(transaction.order))
            }
            // MERCHANT copy
            builder.appendAlignment(SCBAlignmentPosition.center)
            let mdata = try self.build(receiptTemplate: transaction, for: .merchant, store: store, order: order, server: server, settings: settings)
            builder.append(bitmap: mdata)
            builder.appendPaperCut()
            // CUSTOMER copy
            builder.appendAlignment(SCBAlignmentPosition.center)
            let cdata = try self.build(receiptTemplate: transaction, for: .customer, store: store, order: order, server: server, settings: settings)
            builder.append(bitmap: cdata)
            builder.appendPaperCut()
            
            builder.appendBuzz()
        }
    }
    
    func print(closeBatchReport batch: (CCDevice?, [Transaction], Transaction), store: Store, byServer server: Employee, shift: Shift, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { _ in
            try self.build(closeBatchReportTemplate: batch, store: store, byServer: server, shift: shift)
        }
    }

    func print(totalReportByPaymentType store: Store, fromDate: Date, toDate: Date, shift: Int, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { _ in
            try self.build(totalReportByPaymentTypeTemplate: store, fromDate: fromDate, toDate: toDate, shift: shift)
        }
    }
    
    func print(totalReportByArea store: Store, fromDate: Date, toDate: Date, shift: Int, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { _ in
            try self.build(totalReportByAreaTemplate: store, fromDate: fromDate, toDate: toDate, shift: shift)
        }
    }
    
    func print(byPaymentTypeReport store: Store, fromDate: Date, toDate: Date, shift: Int, area: String, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { _ in
            try self.build(byPaymentTypeReportTemplate: store, fromDate: fromDate, toDate: toDate, shift: shift, area: area)
        }
    }
    
    func print(byServerReport store: Store, fromDate: Date, toDate: Date, shift: Int, employee: String, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { _ in
            employee.isEmpty
                ? try self.build(byEmployeeSummaryReportTemplate: store, fromDate: fromDate, toDate: toDate, shift: shift)
                : try self.build(byEmployeeDetailReportTemplate: store, fromDate: fromDate, toDate: toDate, shift: shift, employee: employee)
        }
    }
    
    func print(shiftAndDayReport rows: [NameValueReportRow], byEmployee employee: Employee, fromDate: Date, toDate: Date, shift: Int, toPrinter printer: Printer) -> Single<Void> {
        return send(to: printer) { _ in
            try self.build(shiftAndDayReportTemplate: rows, byEmployee: employee, fromDate: fromDate, toDate: toDate, shift: shift)
        }
    }
}
