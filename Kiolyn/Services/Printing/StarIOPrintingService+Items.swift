//
//  StarIOPrintingService+Items.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import AwaitKit

extension StarIOPrintingService {
    
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
    func build(itemsTemplate items: [OrderItem], ofOrder order: Order, byServer server: Employee, withType type: PrintItemsType, using ds: DataService) throws -> NSAttributedString {
        // The final data
        let data = NSMutableAttributedString(string: "")

        // Load printer settings
        guard items.count > 0 else {
            return data
        }
        // Load print settings (or just use a default one if not exist)
        let settings: KitchenPrintingSettings = try await(ds.load(order.storeID)) ?? KitchenPrintingSettings()
        
        // 3 spaces on top
        data.append("\n\n\n")
        if settings.printServerName {
            // Server: John
            data.append("Server: \(server.name)\n")
        }
        data.append("\n")
        // 05/22/2016
        if settings.printDate || settings.printTime {
            var time = order.createdTime
            let dateValueString = settings.printDate ? time.toString("MM/dd/yyyy") : "          "
            let timeValueString = settings.printTime ? time.toString("HH:mm:ss") : "        "
            data.append("\(dateValueString)                              \(timeValueString)\n")
        }
        // Order #
        if settings.printTransaction {
            var status: String!
            switch type {
            case .void: status = " (VOID)"
            case .resend: status = " (RESEND)"
            case .send: status = ""
            }
            data.append("Order#: ")
            data.appendX2("\(String(format: "%d", order.orderNo))\(status!)\n")
        }
        // TABLE 5                              #Guests:  4
        if settings.printTableNo || settings.printNoOfGuest {
            let guestNumber = settings.printNoOfGuest ? String(format: "Guests:%2d", order.persons) : ""
            let tableName = settings.printTableNo ? order.tableName : ""
            data.appendX2("\(tableName.exact(14)) \(guestNumber)\n")
        }
        // The Items
        data.appendX2("------------------------\n")

        func add(items: [OrderItem]) {
            for item in items {
                // Updated status line
                if item.isUpdated {
                    data.appendX2("    [UPDATED]\n")
                }
                // Name line
                var name = item.samelineName
                // Mark as togo
                if item.togo { name = "[TOGO] \(name)" }
                // Print items (voided items with minus sign)
                if (type == .void) {
                    data.appendX2("-\(item.count.asCount) \(name.left(19))\n")
                    if name.count > 19 {
                        data.appendX2("     \(name.right(from: 19))\n")
                    }
                    // Name 2
                    if settings.printItemsName2, item.name2.isNotEmpty {
                        data.appendX2("     \(item.name2)\n")
                    }
                } else {
                    data.appendX2("\(item.count.asCount) \(name.left(20))\n")
                    if (name.count > 20) {
                        data.appendX2("    \(name.right(from: 20))\n")
                    }
                    // Name 2
                    if settings.printItemsName2, item.name2.isNotEmpty {
                        data.appendX2("    \(item.name2)\n")
                    }
                }
                // Print Note
                if settings.printNote, item.note.isNotEmpty {
                    data.appendX2("    >>\(item.note.left(17))\n")
                    if item.note.count > 17 {
                        data.appendX2("      \(item.note.right(from: 17))\n")
                    }
                }
                // Print modifiers
                if (settings.printModifier) {
                    for opt in item.options {
                        let optName = opt.0
                        data.appendX2("    >>\(optName.left(17))\n")
                        if (optName.count > 17) {
                            data.appendX2("      \(optName.right(from: 17))\n")
                        }
                    }
                }
                // Separator
                data.appendX2("------------------------\n")
            }
        }
        // Group by category (issue #487)
        if settings.printGrouping {
            var categoryItems: [String:[OrderItem]] = [:]
            // Group order items by its category id
            for item in items {
                categoryItems[item.categoryID] = (categoryItems[item.categoryID] ?? []) + [item]
            }
            // This seems to be redundant however, we keep it here to honor the order of category
            let categories: [Category?] = try await(ds.load(multi: categoryItems.keys.unique()))
            let groupedItems: [(Category, [OrderItem])] = categories
                // Remove the nil Category, this is rarely happens, but just in case
                .filter { $0 != nil }
                .map { $0! }
                // Sort category by its order
                .sorted { (cat1, cat2) -> Bool in cat1.order > cat2.order }
                // Replace category id with category
                .compactMap { category -> (Category, [OrderItem]) in
                    return (category, categoryItems[category.id]!)
            }
            // Print items
            for (_, items) in groupedItems {
                add(items: items)
            }
        } else {
            add(items: items)
        }

        // Print customer information
        if order.customer.isNotEmpty,
            // load and make sure customer can be loaded
            let customer: Customer = try await(ds.load(order.customer)) {
            data.append("\n")
            if customer.name.count > 13 {
                data.appendX2("\(customer.name)\n")
                data.appendX2("\(customer.mobilephone)\n")
            } else {
                data.appendX2("\(customer.name) \(customer.mobilephone)\n")
            }
            data.appendX2("\(customer.address), \(customer.city), \(customer.state) \(customer.zip)\n\n")
        }
        // 2 spaces at bottom
        data.append("\n\n")
        return data
    }
}
