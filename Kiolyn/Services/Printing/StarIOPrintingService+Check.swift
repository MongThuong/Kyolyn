//
//  AttributedString+Check.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import AwaitKit

// MARK: - Bill related
extension StarIOPrintingService {
    
    /// Check to cache Image
    ///
    /// - Parameters:
    ///  - url: The image url
    /// - Returns: UImage
    func downloadImage(_ image: Image? ) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        if let dstPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let prefix = "store_logo_"
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: "\(dstPath)/\(prefix)\(image.file)"))
                return UIImage(data: data, scale: UIScreen.main.scale)!
            } catch {
                e(error)
                do {
                    // delete all file with prefix "logo_"
                    let files = try FileManager.default.contentsOfDirectory(atPath: dstPath)
                    for fileName in files {
                        if fileName.hasPrefix(prefix) {
                            try FileManager.default.removeItem(atPath: "\(dstPath)/\(fileName)")
                        }
                    }
                    
                    // write into local file
                    let data = try Data(contentsOf: image.url!)
                    try data.write(to: URL(fileURLWithPath: "\(dstPath)/\(prefix)\(image.file)"))
                    return UIImage(data: data, scale: UIScreen.main.scale)!
                } catch {
                    e(error)
                    return nil
                }
            }
        }
        return nil
    }
    
    
    /// Build printing template for a Check receipt.
    ///
    /// - Parameters:
    ///   - for: The `Bill` to print for
    ///   - order: The `Order` owns the printed `Bill`.
    ///   - server: The `Employee` who request the printing.
    ///   - db: The database for querying data.
    /// - Returns: The data to be printed as `NSAttributedString`.
    /// - Throws: `PrintError`.
    func build(checkTemplate bill: Bill, ofOrder order: Order, byServer server: Employee, using ds: DataService) throws -> NSAttributedString {
        // The final data
        let data = NSMutableAttributedString(string:"")
        // Load store and print settings
        guard let store: Store =  try await(ds.load(order.storeID)) else {
                return data
        }
        // Load print settings (or just use a default one if not exist)
        let settings: CheckReceiptPrintingSettings = try await(ds.load(order.storeID)) ?? CheckReceiptPrintingSettings()
        
        //Center Alignment
        if settings.printLogo, let storeLogo = downloadImage(store.logo ?? nil) { /* TODO print the logo */
            let storeLogoAttachment = NSTextAttachment.init()
            let ratio = storeLogo.size.width / storeLogo.size.height
            let height: CGFloat = 120
            let with = height * ratio
            storeLogoAttachment.bounds = CGRect(x: 0, y: 0, width: with, height: height)
            storeLogoAttachment.image = storeLogo
            
            let iconString = NSAttributedString(attachment: storeLogoAttachment)
            let logoString = NSMutableAttributedString(attributedString: iconString)
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 10.0
            paragraph.alignment = .center
            let attributes = [NSAttributedStringKey.paragraphStyle: paragraph]
            logoString.addAttributes(attributes, range: NSMakeRange(0, iconString.length))
            
            data.append("\n")
            data.append(logoString)
            data.append("\n")
            data.append("\n")
        }
        if settings.printStoreName {
            data.appendCenterX2("\(store.storeName)\n")
        }
        if settings.printAddress {
            data.appendCenter("\(store.bizAddress)\n")
            data.appendCenter("\(store.bizCity), \(store.bizState) \(store.bizZip)\n")
        }
        if settings.printPhone {
            data.appendCenter("\(store.bizPhone)\n")
        }
        // Make space
        data.append("\n")
        // Server
        if settings.printServerName {
            data.append("Server: \(server.name)\n")
        }
        
        // Date time
        if settings.printDateTime {
            let time = order.createdTime
            data.append("\(time.toString("MM/dd/yyyy"))                              \(time.toString("HH:mm:ss"))\n")
        }
        
        // Order and Bill number
        data.append("\n")
        data.appendX2("Order#: \(order.orderNo) (Bill \(order.bills.index(of: bill)! + 1) of \(order.bills.count))\n")
        
        // TABLE AND GUESTS
        if settings.printTableNo || settings.printNoOfGuest {
            let tableNo = settings.printTableNo ? order.tableName : ""
            let noOfGuest = settings.printNoOfGuest ? String(format: "Guests:%2d", order.persons) : ""
            data.appendBoldX2("\(tableNo.exact(14)) \(noOfGuest)\n")
        }
        // Seperator
        data.append("------------------------------------------------\n")
        for item in bill.items {
            var name1 = "", name2 = ""
            if settings.printItemsName1 {
                name1 = item.name
                if settings.printItemsName2 {
                    name2 = item.name2
                }
            } else if settings.printItemsName2 {
                name1 = item.name2
            } else {
                name1 = item.name
            }
            
            let nameLength = 30
            data.append("\(item.count.asCount) x \(name1.exact(nameLength)) \(item.samelineSubtotal.asPrintingMoney)\n")
            if name1.count > nameLength {
                data.append("      \(name1.right(from: nameLength))\n")
            }
            if name2.isNotEmpty {
                data.append("      \(name2.left(nameLength))\n")
                if name2.count > nameLength {
                    data.append("      \(name2.right(from: nameLength))\n")
                }
            }
            if item.hasNote {
                data.append("      \(item.note.exact(nameLength)) \(item.noteSubtotal.asPrintingMoney)\n")
                if item.note.count > nameLength {
                    data.append("      \(item.note.left(nameLength))\n")
                }
            }
            
            if item.modifiers.isNotEmpty {
                for option in item.options {
                    let (name, amount) = option
                    data.append("      \(name.exact(nameLength)) \(amount.asPrintingMoney)\n")
                    if name.count > nameLength {
                        data.append("      \(name.right(from: nameLength))\n")
                    }
                }
            }
        }
        data.append("------------------------------------------------\n")
        // Summary
        let nameLen = 36
        data.appendBold("Subtotal".padRight(nameLen))
        data.append(" \(bill.subtotal.asPrintingMoney)\n")
        if bill.tax.percent > 0 {
            data.append("\(bill.tax.name) (\(bill.tax.percent.asPercentage))".exact(nameLen), bold: true, center: false, size: printingFontSizeBase*0.99)
            data.append(" \(bill.taxAmount.asPrintingMoney)\n")
        }
        if bill.discount.finalPercent > 0 {
            data.append("\(bill.discount.name) (\(bill.discount.percent.asPercentage))".exact(nameLen), bold: true, center: false, size: printingFontSizeBase*0.99)
            data.append(" \(bill.discountAmount.asPrintingMoney)\n")
        }
        if bill.serviceFeeAmount > 0 {
            data.appendBold("Group Gratuity (\((bill.serviceFee * 100).format("%.02f"))%)".exact(nameLen))
            data.append(" \(bill.serviceFeeAmount.asPrintingMoney)\n")
        }
        if bill.serviceFeeTaxAmount > 0 {
            data.appendBold("Group Gratuity Tax (\((bill.serviceFeeTax * 100).format("%.02f"))%)".exact(nameLen))
            data.append(" \(bill.serviceFeeTaxAmount.asPrintingMoney)\n")
        }
        if bill.customServiceFeeAmount > 0 {
            let extra = bill.customServiceFeePercent > 0
                ? " (\(bill.customServiceFeePercent.asPercentage))"
                : ""
            data.appendBold("Service Fee\(extra)".exact(nameLen))
            data.append(" \(bill.customServiceFeeAmount.asPrintingMoney)\n")
        }
        // BIG-BOLD font
        data.appendBoldX2("Total \(bill.total.asMoney.padLeft(18))\n")
        data.append("------------------------------------------------\n")
        // Customer
        if let customer: Customer = try await(ds.load(order.customer)) {
            data.appendBold("Delivery Address\n")
            var line1 = ""
            if customer.name.isNotEmpty {
                line1 += customer.name
            }
            if customer.mobilephone.isNotEmpty {
                if line1.isEmpty { line1 += customer.mobilephone.formattedPhone }
                else { line1 += " - \(customer.mobilephone.formattedPhone)" }
            }
            data.append("\(line1)\n")
            
            if customer.address.isNotEmpty {
                var line2 = customer.address
                if customer.city.isNotEmpty {
                    line2 += ", \(customer.city)"
                }
                if customer.state.isNotEmpty {
                    line2 += " \(customer.state)"
                }
                if customer.zip.isNotEmpty {
                    line2 += " \(customer.zip)"
                }
                data.append("\(line2)\n")
            }
            data.append("------------------------------------------------\n")
        }
        // Tips
        if settings.printTipGuide {
            for tip in settings.tips {
                let tipAmount = (tip.percent * bill.total).asPrintingMoney
                let totalAmount = ((tip.percent + 1) * bill.total).asPrintingMoney
                data.append("[  ]  \(String(format: "%.02f", tip))%  (Tip \(tipAmount), Total \(totalAmount))\n")
            }
        }
        data.append("\n")
        if settings.printText1 {
            data.appendCenter("\(settings.text1)\n")
        }
        data.append("\n")
        // PAID INFO
        if bill.paid, let transaction: Transaction = try await(ds.load(bill.transaction)) {
            data.append("------------------------------------------------\n")
            data.appendBold("PAID BY \(transaction.paidInfo.padRight(28)) \(transaction.approvedAmount.asPrintingMoney)")
        }
        return data
    }
}

