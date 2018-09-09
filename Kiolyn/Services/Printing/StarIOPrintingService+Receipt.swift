//
//  StarIOPrintingService+Receipt.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension StarIOPrintingService {
    /// Build printing template for a Check receipt.
    ///
    /// - Parameters:
    ///   - for: The `Bill` to print for
    ///   - server: The `Employee` who request the printing.
    ///   - for: The type of Receipt.
    ///   - db: The database for querying data.
    /// - Returns: The data to be printed as `NSAttributedString`.
    /// - Throws: `PrintError`.
    func build(receiptTemplate trans: Transaction, for type: PrintReceiptType, store: Store, order: Order?, server: Employee, settings: CCReceiptPrintingSettings) throws -> NSAttributedString {
        // The final data
        let data = NSMutableAttributedString(string:"")
        // 2 spaces on top
        data.append("\n\n")
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
        if settings.printDateTime {
            data.appendCenter("\(trans.createdTime.toString("MMM d yyyy HH:mm"))\n")
        }
        if settings.printMerchantID {
            data.appendCenter("Store ID: \(store.id)\n")
        }
        if store.storeMerchantID.isNotEmpty {
            data.appendCenter("Merchant ID: \(store.storeMerchantID)\n")
        }
        if store.terminalID.isNotEmpty {
            data.appendCenter("Terminal ID: \(store.terminalID)\n")
        }
        // Make space
        data.append("\n")
        data.appendCenterX2("\(trans.printingTransType)\n")
        // Single space after the title (issue #399)
        data.append("\n")
        // Print table name if Order is available (issue #399)
        if let order = order {
            if settings.printTableNo {
                if order.tableName.hasPrefix("Table") {
                    data.appendX2("\(order.tableName)\n")
                } else {
                    data.appendX2("Table \(order.tableName)\n")
                }
            }
            if settings.printOrderNo == true {
                data.appendX2("Order#: \(order.orderNo)\n")
            }
        }
        
        if settings.printTransactionNo {
            data.appendX2("Transaction#: \(trans.transNum)\n")
        }
        
        if trans.transType != .cash && trans.transType != .custom {
            if settings.printCardType {
                data.append("Card Type: \(trans.cardType)\n")
            }
            if settings.printCardNo {
                data.append("Account Number: XXXX XXXX XXXX \(trans.cardNum)\n")
            }
            if settings.printAuthCode {
                data.append("Auth Code: \(trans.authCode)\n")
            }
        }
        
        // Make space
        data.append("\n")
        
        // BIG-BOLD font
        data.appendBoldX2("Amount: \(trans.approvedAmount.asMoney)\n")
        
        if trans.transType == .creditSale && !trans.isVoided {
            if trans.approvedAmount < trans.requestedAmount {
                data.append("Approved Amount: \(trans.approvedAmount.asMoney)\n")
                data.append("Amount Due: \((trans.requestedAmount - trans.approvedAmount).asMoney)\n")
            } else if trans.tipAmount > 0 {
                data.appendBoldX2("Tip:    \(trans.tipAmount.asMoney)\n")
                data.appendBoldX2("Total:  \((trans.tipAmount + trans.approvedAmount).asMoney)\n")
            } else if settings.printTipGuide {
                data.append("\n")
                data.appendBoldX2("Tip:    $ ______________\n")
                data.append("\n")
                for tip in settings.tipGuides {
                    data.appendBold("[ ] Tip\((tip * 100).format("%.1f").padLeft(5))%")
                    data.append(" (Tip\((trans.approvedAmount * tip).asMoney.padLeft(10)), Total\((trans.approvedAmount * (1.0 + tip)).asMoney.padLeft(11)))\n")
                }
                data.append("\n")
                data.appendBoldX2("Total:  $ ______________\n")
                data.append("\n")
            }
        } else if trans.transType == .cash || trans.transType == .custom {
            if trans.tipAmount > 0 {
                data.appendBoldX2("Tip:    \(trans.tipAmount.asMoney)\n")
                data.appendBoldX2("Total:  \((trans.tipAmount + trans.approvedAmount).asMoney)\n")
            }
        } else {
            data.append("\n\n\n")
        }
        
        if type == .merchant {
            data.append("\n")
            if settings.printText1 && settings.text1.isNotEmpty {
                data.append("\(settings.text1)\n")
            }
            data.append("\n\n\n")
            data.append("x ______________________________________________\n")
        }
        
        data.append("\n")
        
        if settings.printText2 && settings.text2.isNotEmpty {
            data.appendCenter("\(settings.text2)\n")
        }
        
        if type == .merchant {
            data.appendCenter("Merchant Copy")
        } else {
            data.appendCenter("Customer Copy")
        }
        
        // Give some space at the bottom (issue #399)
        data.append("\n\n")
        
        return data
    }
}
