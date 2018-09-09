//
//  DatabaseLoadingTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Kiolyn

public class DatabaseLoadingTests: BaseTests {
    override public func spec() {
        
        let storeID = "17021812551554" // Nam Hoa
        
        beforeSuite {
            self.preload(localDbName: "namhoa")
        }
        
        describe("Couchbase Database") {
            
            it("can save a Store as [String: Any]") {
                // Assume this is what we got from a call to Sync Session
                let properties: [String: Any] = [
                    "type": "store",
                    "merchantid": "15121510073220",
                    "id": storeID,
                    "biz_country": "Vietnam",
                    "store_name": "Nam Hòa",
                    "biz_city": "HCM",
                    "biz_state": "Ho Chi Minh",
                    "biz_phone": "0909117758",
                    "biz_address": "Somewhere in Saigon",
                    "biz_zip": "70000",
                    "merchant_id": "12345",
                    "terminal_id": "890",
                    "sync_session": [
                        "cookie_name": "SyncGatewaySession",
                        "session_id": "aca85f9fabe9c6977b34c25fecaa9e789f73318b",
                        "expires": SyncSession.expiresFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
                    ]
                ]
                
                expect {
                    try! self.database.save(properties)
                }.toNot(throwError())
            }
            
            it("can load a Store") {
                // Validate it
                guard let store: Store = self.database.load(storeID) else {
                    return fail("Could not load Store")
                }
                expect(store.id) == storeID
                expect(store.merchantID) == "15121510073220"
                expect(store.storeName) == "Nam Hòa"
                expect(store.bizAddress) == "Somewhere in Saigon"
                expect(store.bizCity) == "HCM"
                expect(store.bizPhone) == "0909117758"
                expect(store.bizState) == "Ho Chi Minh"
                expect(store.bizZip) == "70000"
                expect(store.storeMerchantID) == "12345"
                expect(store.terminalID) == "890"
            }
            
            it("can load a Station for a Store using MAC address") {
                // Validate it
                guard let station: Station = self.database.load(storeID, mac: "9CB70D793fb8") else {
                    return fail("Could not load Store")
                }
                expect(station.storeID) == storeID
                expect(station.id) == "17030212282125"
                expect(station.merchantID) == "15121510073220"
                expect(station.enabled) == true
                expect(station.main) == true
                expect(station.location) == ""
                expect(station.name) == "Chinh"
                expect(station.macAddress.lowercased()) == "9CB70D793fb8".lowercased()
                expect(station.stationType) == StationType.ipad
            }
            
            it("can load an Employee from a Store using passkey") {
                guard let employee: Employee = self.database.load(storeID, passkey: "11111") else {
                    return fail("Could not load Employee")
                }
                expect(employee.storeID) == storeID
                expect(employee.name) == "TrucHeo"
                expect(employee.permissions.adjustPrice) == false
                expect(employee.permissions.changeOrderTax) == false
                expect(employee.permissions.customer) == false
                expect(employee.permissions.deleteEditSentItem) == false
                expect(employee.permissions.maxDiscount) == 0.0
                expect(employee.permissions.order) == true
                expect(employee.permissions.refundVoidUnpaidSettle) == false
                expect(employee.permissions.report) == false
            }
            
            it("can load Store Settings") {
                guard let settings: Settings = self.database.load(storeID) else {
                    return fail("Could not load Settings")
                }
                expect(settings.id) == storeID
                
                // Timeout
                expect(settings.timeout) == 300
                
                // Taxes
                expect(settings.taxes.count) == 1
                // Berkeley tax
                expect(settings.taxes.first!.name) == "Berkeley Tax"
                expect(settings.taxes.first!.percent) == 0.1
                expect(settings.taxes.first!.isDefault) == true
                
                // Discounts
                expect(settings.discounts.count) == 4
                // 1st
                expect(settings.discounts[0].name) == "Employee"
                expect(settings.discounts[0].percent) == 0.1
                // 2nd
                expect(settings.discounts[1].name) == "Friend"
                expect(settings.discounts[1].percent) == 0.15
                // 3rd
                expect(settings.discounts[2].name) == "Family"
                expect(settings.discounts[2].percent) == 0.2
                // 4th
                expect(settings.discounts[3].name) == "VIP"
                expect(settings.discounts[3].percent) == 0.5
                
                // Payment types
                expect(settings.paymentTypes.count) == 7
                
                // Gift Card
                expect(settings.paymentTypes[0].name) == "Gift Card"
                expect(settings.paymentTypes[0].subPaymentTypes.count) == 2
                expect(settings.paymentTypes[0].subPaymentTypes[0].name) == "GC 1"
                expect(settings.paymentTypes[0].subPaymentTypes[1].name) == "GC 2"
                
                // Check
                expect(settings.paymentTypes[1].name) == "Check"
                expect(settings.paymentTypes[1].subPaymentTypes.count) == 2
                expect(settings.paymentTypes[1].subPaymentTypes[0].name) == "C 1"
                expect(settings.paymentTypes[1].subPaymentTypes[0].name) == "C 1"
                
                // Eat24
                expect(settings.paymentTypes[2].name) == "Eat24"
                
                // Waiter.Com
                expect(settings.paymentTypes[3].name) == "Waiter.Com"
                
                // DoorDash
                expect(settings.paymentTypes[4].name) == "DoorDash"
                
                // PaxS80
                expect(settings.paymentTypes[5].name) == "PaxS80"
                
                // Vx520
                expect(settings.paymentTypes[6].name) == "Vx520"
                
                
                // Cash sub payment types
                expect(settings.cashSubPaymentTypes.count) == 1
                expect(settings.cashSubPaymentTypes[0].name) == "C 1"
                
                // Card sub payment types
                expect(settings.cardSubPaymentTypes.count) == 2
                expect(settings.cardSubPaymentTypes[0].name) == "CC 1"
                expect(settings.cardSubPaymentTypes[1].name) == "CC 2"
                
                // Group gratuity
                expect(settings.groupGratuityTax) == 0.1
                expect(settings.groupGratuities.count) == 2
                expect(settings.groupGratuities[0].number) == 10
                expect(settings.groupGratuities[0].percent) == 0.05
                expect(settings.groupGratuities[1].number) == 20
                expect(settings.groupGratuities[1].percent) == 0.1
                expect(settings.voidGroupGratuityReasons.count) == 2
                expect(settings.voidGroupGratuityReasons[0].name) == "Family"
                expect(settings.voidGroupGratuityReasons[1].name) == "Friends"
                
                // Reasons
                expect(settings.voidTransactionReasons.count) == 2
                expect(settings.voidTransactionReasons[0].name) == "Wrong Order"
                expect(settings.voidTransactionReasons[1].name) == "Changed Mind"
                
                expect(settings.discountReasons.count) == 2
                expect(settings.discountReasons[0].name) == "Regular Customers"
                expect(settings.discountReasons[1].name) == "Friend of Owner"
                
                expect(settings.voidOrderReasons.count) == 2
                expect(settings.voidOrderReasons[0].name) == "Wrong Order"
                expect(settings.voidOrderReasons[1].name) == "Customer Left"
                
                expect(settings.clockoutReasons.count) == 2
                expect(settings.clockoutReasons[0].name) == "Lunch Time"
                expect(settings.clockoutReasons[0].payableTime) == "6000"
                expect(settings.clockoutReasons[1].name) == "Dinner Time"
                expect(settings.clockoutReasons[1].payableTime) == "6000"
                
                // Category Types
                //                    expect(settings.categoryTypes.count) == 2
                //                    expect(settings.categoryTypes[0].uppercased()) == "BREAKFAST"
                //                    expect(settings.categoryTypes[1].uppercased()) == "COTTON"
                
                // Ordering Settings
                expect(settings.ordering.orderItemSize) == OrderItemSize.normal
                
                // Items ordering settings
                expect(settings.ordering.items.width) == 80
                expect(settings.ordering.items.height) == 80
                expect(settings.ordering.items.col) == 8
                expect(settings.ordering.items.row) == 8
                expect(settings.ordering.items.gutter) == 8
                expect(settings.ordering.items.fontSize) == 16
                expect(settings.ordering.items.totalWidth) == 768
                expect(settings.ordering.items.totalHeight) == 768
                
                // Categories ordering settings
                expect(settings.ordering.categories.width) == 80
                expect(settings.ordering.categories.height) == 80
                expect(settings.ordering.categories.col) == 8
                expect(settings.ordering.categories.row) == 2
                expect(settings.ordering.categories.gutter) == 8
                expect(settings.ordering.categories.fontSize) == 16
                expect(settings.ordering.categories.totalWidth) == 768
                expect(settings.ordering.categories.totalHeight) == 192
            }
            
            it("can load all categories and items") {
                let categories: [Kiolyn.Category] = self.database.load(storeID)
                
                expect(categories.count) == 2
                expect(categories[0].name) == "Viet Nam"
                expect(categories[1].name) == "Thailand"
                
                expect(categories[0].categoryType.uppercased()) == "COTTON"
                expect(categories[1].categoryType.uppercased()) == "BREAKFAST"
                
                expect(categories[0].allowOpenItem) == true
                expect(categories[1].allowOpenItem) == true
                
                expect(categories[0].printers.count) == 1
                expect(categories[0].printers[0].id) == "17030317371155"
                
                // TODO - validate printers
                
                let items: [Item] = self.database.loadItems(storeID, category: categories[0].id)
                
                expect(items.count) == 2
                expect(items[0].name) == "Moods"
                expect(items[1].name) == "Lion"
                
                expect(items[0].price) == 120
                expect(items[1].price) == 120
                
                expect(items[0].hasImage) == true
                expect(items[1].hasImage) == true
                
                expect(items[0].image).toNot(beNil())
                expect(items[0].image!.mime) == "image/jpeg"
                expect(items[0].image!.size) == 138322
                expect(items[0].image!.file) == "2PsZrt90niWIINmb3cKmwJmx"
                
                expect(items[0].printers.count) == 1
                expect(items[0].printers[0].id) == "17030317372684"
                
                expect(items[0].modifiers.count) == 1
                expect(items[0].modifiers[0].id) == "17030317324921"
            }
            
            it("can load all modifiers with options") {
                let modifiers: [Modifier] = self.database.load(storeID)
                
                expect(modifiers.count) == 4
                
                expect(modifiers[0].name) == "Color"
                expect(modifiers[1].name) == "Logo "
                expect(modifiers[2].name) == "Material"
                expect(modifiers[3].name) == "Zip"
                
                expect(modifiers[0].global) == true
                expect(modifiers[1].global) == false
                expect(modifiers[2].global) == false
                expect(modifiers[3].global) == true
                
                expect(modifiers[0].multiple) == false
                expect(modifiers[1].multiple) == false
                expect(modifiers[2].multiple) == true
                expect(modifiers[3].multiple) == true
                
                expect(modifiers[1].required) == false
                expect(modifiers[2].required) == false
                
                expect(modifiers[0].options.count) == 4
                expect(modifiers[1].options.count) == 3
                expect(modifiers[2].options.count) == 2
                expect(modifiers[3].options.count) == 3
                
                
                expect(modifiers[0].options[0].name) == "Black"
                expect(modifiers[0].options[0].price) == 2.0
                expect(modifiers[0].options[1].name) == "Red"
                expect(modifiers[0].options[1].price) == 1.5
                expect(modifiers[0].options[2].name) == "Blue"
                expect(modifiers[0].options[2].price) == 2.0
                expect(modifiers[0].options[3].name) == "White"
                expect(modifiers[0].options[3].price) == 2.0
            }
            
            it("can load all areas with tables") {
                let areas: [Area] = self.database.load(storeID)
                
                expect(areas.count) == 4
                
                expect(areas[0].name) == "Dine-In"
                expect(areas[1].name) == "Pick-Up"
                expect(areas[2].name) == "Delivery"
                expect(areas[3].name) == "To Go"
                
                expect(areas[0].noOfGuestPrompt) == true
                expect(areas[0].customerInfoPrompt) == false
                expect(areas[0].tables.count) == 5
                
                expect(areas[0].tables[0].name) == "Dine-In 1"
                expect(areas[0].tables[0].shape) == TableShape.rectangle
                expect(areas[0].tables[0].maxGuests) == 4
                expect(areas[0].tables[0].width) == 90
                expect(areas[0].tables[0].height) == 90
                expect(areas[0].tables[0].angle) == 0
                expect(areas[0].tables[0].left) == 3
                expect(areas[0].tables[0].top) == 3
                expect(areas[0].tables[0].radiusX) == 45
                expect(areas[0].tables[0].radiusY) == 45
                
                expect(areas[2].tables[0].name) == "Delivery 1"
                expect(areas[2].tables[0].shape) == TableShape.ellipse
                expect(areas[2].tables[0].maxGuests) == 4
                expect(areas[2].tables[0].width) == 90
                expect(areas[2].tables[0].height) == 90
                expect(areas[2].tables[0].angle) == 0
                expect(areas[2].tables[0].left) == 3
                expect(areas[2].tables[0].top) == 3
                expect(areas[2].tables[0].radiusX) == 45
                expect(areas[2].tables[0].radiusY) == 45
            }
            
            it("can load all printers") {
                let printers: [Printer] = self.database.load(storeID)
                
                expect(printers.count) == 3
                
                expect(printers[0].name) == "Cashier 1"
                expect(printers[1].name) == "Cashier 2"
                expect(printers[2].name) == "Cashier 3"
                //                    expect(printers[3].name) == "Cashier 4"
                
                expect(printers[0].location) == "Cashier"
                expect(printers[1].location) == "Cashier"
                expect(printers[2].location) == "Cashier"
                //                    expect(printers[3].location) == "Cashier"
                
                expect(printers[0].printerType) == PrinterType.ethernet
                expect(printers[1].printerType) == PrinterType.bluetooth
                expect(printers[2].printerType) == PrinterType.usb
                //                    expect(printers[3].printerType) == PrinterType.ethernet
                
                expect(printers[0].isValid) == true
                expect(printers[1].isValid) == true
                expect(printers[2].isValid) == true
            }
        }
    }
}
