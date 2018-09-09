//
//  BrotherLabelPrintingService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import AwaitKit

class BrotherLabelPrintingService: LabelPrintingService {
    
    fileprivate let queue = DispatchQueue(label: "com.kiolyn.labelprinting", attributes: .concurrent)
    
    /// Build string template for printing items.
    ///
    /// - Parameters:
    ///   - items: The `Item`s to print.
    ///   - order: The `Order` that the orders belong to.
    ///   - server: The server who request the printing.
    ///   - type: The type of printing.
    ///   - ds: The data service for querying data.
    /// - Returns: The data to be printed as `NSAttributedString`.
    /// - Throws: `PrintError`.
    func build(itemsTemplate items: [OrderItem], ofOrder order: Order, withType type: PrintItemsType, and settings: LabelPrintingSettings) throws -> NSAttributedString {
        // The final data
        let data = NSMutableAttributedString(string: "")
        
        // Load printer settings
        guard items.count > 0 else {
            return data
        }
        // 05/22/2016
        if settings.printDate || settings.printTime {
            let time = order.createdTime
            let dateValueString = settings.printDate ? time.toString("MM/dd/yyyy") : "          "
            let timeValueString = settings.printTime ? time.toString("HH:mm:ss") : "        "
            data.append("\(dateValueString)                                        \(timeValueString)\n")
        }
        // Order #
        if settings.printOrderNo {
            data.append("Order#: ")
            data.appendX2("\(String(format: "%d", order.orderNo))\n")
        }
        // TABLE 5
        if settings.printTableNo {
            data.appendX2("\(order.tableName)\n")
        }
        // ITEMS
        let nl = 25 // Name length
        let cl = 3 // Count length
        let ml = nl - cl // Modifier length
        for (index, item) in items.enumerated() {
            // Name line
            let name = item.samelineName
            // Print items
            if settings.printSeparateItem {
                data.appendX2("    \(name.left(nl))\n")
            } else {
                data.appendX2("\(item.count.asCount) \(name.left(nl))\n")
            }
            if (name.count > nl) {
                data.appendX2("    \(name.right(from: nl))\n")
            }
            // Name 2
            if settings.printItemsName2, item.name2.isNotEmpty {
                data.appendX2("    \(item.name2)\n")
            }
            // Print Note
            if settings.printNote, item.note.isNotEmpty {
                data.appendX2("    >>\(item.note.left(ml))\n")
                if item.note.count > ml {
                    data.appendX2("      \(item.note.right(from: ml))\n")
                }
            }
            // Print modifiers
            if settings.printModifier {
                for opt in item.options {
                    let optName = opt.0
                    data.appendX2("    >>\(optName.left(ml))\n")
                    if (optName.count > ml) {
                        data.appendX2("      \(optName.right(from: ml))\n")
                    }
                }
            }
            // Separator
            if index < items.count - 1 {
                data.appendX2("-----------------------------\n")
            }
        }
        
        return data
    }
    
    /// Find a printer's IP address.
    ///
    /// - Parameter printer: the printer to find.
    /// - Returns: the printer's IP address in current network.
    private func findIP(printer: Printer) -> String? {
        return BrotherPrinterFinder().findIP(printer: printer)
    }
    
    /// Send an image to printer.
    ///
    /// - Parameters:
    ///   - printer: the target printer.
    ///   - image: the image to send.
    /// - Throws: Any `PrintError`.
    private func send(to printer: Printer, images: [UIImage]) throws {
        #if DEBUG
        for image in images {
            let filePath = try image.save(toTempDirectory: "label_\(UUID().compressedUUIDString).png")
            d("Printed to \(filePath)")
        }
        #endif
        guard !Configuration.testPrinting else { return }

        // Create the brother printer
        guard let brpPrinter = BRPtouchPrinter(printerName: printer.printerModel.name, interface: .WLAN) else {
            throw PrintError.printingError(detail: "Could not create BRP Touch Printer")
        }
        brpPrinter.setIPAddress(printer.ipAddress)
        guard brpPrinter.isPrinterReady() else {
            throw PrintError.printingError(detail: "Printer's not ready")
        }
        guard brpPrinter.startCommunication() else {
            throw PrintError.printingError(detail: "Could tno start commnication")
        }
        let printInfo = BRPtouchPrintInfo()
        printInfo.strPaperName = "62mmRB"
        printInfo.bEndcut = true
        printInfo.bPeel = true
        brpPrinter.setPrintInfo(printInfo)
        
        var err: Error? = nil
        do {
            for image in images {
                let printResult = brpPrinter.print(image.cgImage, copy: 1)
                if printResult != 0 {
                    throw PrintError.printingError(detail: "Print failed with code \(printResult)")
                }
            }
        } catch {
            err = error
        }
        brpPrinter.endCommunication()
        // Make sure error got rethrown
        if let error = err {
            throw error
        }
    }
    
    func print(items: [[OrderItem]], ofOrder order: Order, withType type: PrintItemsType, toPrinter printer: Printer) -> Single<Void> {
        return queue.ak.async {
            let ds = SP.dataService
            // Find printers and update its IP address
            if !Configuration.testPrinting && printer.noIPAddress {
                guard let ip = self.findIP(printer: printer), ip.isNotEmpty else {
                    throw PrintError.printerNotFound
                }
                printer.ipAddress = ip
                _ = try await(ds.save(printer))
                // If there is no IP even after searching then there nothing to perform
                guard printer.ipAddress.isNotEmpty else {
                    throw PrintError.printerNotFound
                }
            }
            #if DEBUG
            let dstPath = NSTemporaryDirectory()
            let files = try FileManager.default.contentsOfDirectory(atPath: dstPath)
            for fileName in files {
                if fileName.hasPrefix("label_") {
                    try FileManager.default.removeItem(atPath: "\(dstPath)/\(fileName)")
                }
            }
            #endif
            // Build and send list of OrderItems
            let buildImages = { (items: [OrderItem], settings: LabelPrintingSettings) throws -> [UIImage] in
                let content = try self.build(itemsTemplate: items, ofOrder: order, withType: type, and: settings)
                let image = content.rasterize(width: 720)
                if settings.printSeparateItem, items.count == 1, let item = items.first {
                    return [UIImage](repeating: image, count: Int(item.count))
                } else {
                    return [image]
                }
            }
            // Build image and send to printer the whole list of items
            let buildAndSend = { (settings: LabelPrintingSettings) throws in
                // Build content
                var images: [UIImage] = []
                for its in items {
                    if settings.printSeparateItem {
                        for it in its {
                            images.append(contentsOf: try buildImages([it], settings))
                        }
                    } else {
                        images.append(contentsOf: try buildImages(its, settings))
                    }
                }
                try self.send(to: printer, images: images)
            }
            
            // Load print settings (or just use a default one if not exist)
            let settings: LabelPrintingSettings = try await(SP.dataService.load(order.storeID)) ?? LabelPrintingSettings()
            do {
                // Try to build content and send
                try buildAndSend(settings)
            } catch {
                w("Failed sending data to printer \(error)")
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
                do {
                    try buildAndSend(settings)
                } catch {
                    e("Failed sending data to printer \(error)")
                    throw PrintError.failedSendingPrintingData
                }
            }
        }
    }
}

private class BrotherPrinterFinder: NSObject, BRPtouchNetworkDelegate {
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var networkManager: BRPtouchNetworkManager?
    
    /// Find the printer
    ///
    /// - Parameter printer: the printer to find.
    /// - Returns: the found IP or nothing.
    func findIP(printer: Printer) -> String? {
        networkManager = BRPtouchNetworkManager(printerName: printer.printerModel.name)
        guard let nm = networkManager else {
            return nil
        }
        nm.delegate = self
        nm.isEnableIPv6Search = false
        nm.setPrinterNames([printer.printerModel.name])
        DispatchQueue.main.async {
            nm.startSearch(5)
        }
        _ = self.semaphore.wait(timeout: .distantFuture)
        return nm.getPrinterNetInfo()
            .map { info in info as? BRPtouchDeviceInfo }
            .filterNil()
            .first { info in info.strMACAddress.rawMac.lowercased() == printer.macAddress.lowercased() }
            .map { info in info.strIPAddress! }
    }
    
    func didFinishSearch(_ sender: Any!) {
        semaphore.signal()
    }
}




