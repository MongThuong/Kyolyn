//
//  PrintingTests.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/20/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import Kiolyn

public class PrintingTests: BaseTests {
    override public func spec() {
        
        let storeID = "17021812551554" // Nam Hoa
        
        beforeSuite {
            self.preload(localDbName: "namhoa")
        }
        
        describe("Couchbase Database") {
            
            it("can load a kitchen printing settings") {
                // Validate it
                guard let settings: KitchenPrintingSettings = self.database.load(storeID) else {
                    return fail("Could not load Print Settings")
                }
 
                expect(settings.printDate) == true
                expect(settings.printTime) == true
                expect(settings.printGrouping) == true
                expect(settings.printNote) == true
                expect(settings.printItemsName1) == true
                expect(settings.printItemsName2) == true
                expect(settings.printNoOfGuest) == true
                expect(settings.printTransaction) == true
                expect(settings.printTableNo) == true
                expect(settings.printModifier) == true
                expect(settings.printServerName) == true
            }
            
//            /// Test kitchen receipt
//            /// - build string
//            /// - send string to printer
//            it("can build kitchen receipt") {
//                // Validate it
//                guard let settings: KitchenPrintingSettings = self.database.load(storeID) else {
//                    return fail("Could not load Print Settings")
//                }
//        
//                guard let employee: Employee = self.database.load(storeID, passkey: "11111") else {
//                    return fail("Could not load Employee")
//                }
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let printItemsType = PrintItemsType.void
//                
//                var items: [Item] = [Item]()
//                
//                let categories: [Kiolyn.Category] = self.database.load(storeID)
//                
//                for category in categories {
//                    let itemCategory: [Item] = self.database.loadItems(storeID, category: category.id)
//                    items.append(contentsOf: itemCategory)
//                }
//                
//                var orderItems = [OrderItem]()
//                for item in items {
//                    orderItems.append(OrderItem.init(for: item))
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//               
//                let customer = Customer(forNewDocumentIn: self.database.database!)
//                customer.name = "Thinh Lai"
//                customer.mobilephone = "0933918294"
//                customer.address = "Somewhere in Saigon"
//                customer.city = "HCM"
//                customer.state = "Viet Nam"
//                customer.zip = "70000"
//            
//                do {
//                    let order: Order = try Order.new(in: self.database.database!, store: store, shift: shift, employee: employee)
//                    order.id = "17032808302014" // hard code create time
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = printingService.buildPrintItemsData(order: order, items: orderItems, server: employee, settings: settings, type: printItemsType, categories: categories, customer: customer)
//                    let expectedResult = "\n" +
//                        "\n" +
//                        "\n" +
//                        "Server: TrucHeo\n" +
//                        "\n" +
//                        "03/28/2017      08:30:20\n" +
//                        "Order#: 01 (VOID)\n" +
//                        "              Guests: 01\n" +
//                        "------------------------\n" +
//                        "Viet Nam\n" +
//                        "------------------------\n" +
//                        "-1  Moods\n" +
//                        "------------------------\n" +
//                        "-1  Lion\n" +
//                        "------------------------\n" +
//                        "Thailand\n" +
//                        "------------------------\n" +
//                        "-1  Beer\n" +
//                        "------------------------\n" +
//                        "-1  Weird\n" +
//                        "------------------------\n" +
//                        "\n" +
//                        "Thinh Lai 0933918294\n" +
//                        "Somewhere in Saigon, HCM, Viet Nam 70000\n" +
//                        "\n" +
//                        "\n" +
//                        "\n" +
//                        "\n"
//    
//                    expect(textPrint.string) == expectedResult
//                    
//                } catch _ {
//                    return fail("Could not create Order")
//                }
//            }
//
//            it("can send kitchen receipt to printer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                // Validate it
//                guard let settings: KitchenPrintingSettings = self.database.load(storeID) else {
//                    return fail("Could not load Print Settings")
//                }
//                
//                guard let employee: Employee = self.database.load(storeID, passkey: "11111") else {
//                    return fail("Could not load Employee")
//                }
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let printItemsType = PrintItemsType.void
//                
//                var items: [Item] = [Item]()
//                
//                let categories: [Kiolyn.Category] = self.database.load(storeID)
//                
//                for category in categories {
//                    let itemCategory: [Item] = self.database.loadItems(storeID, category: category.id)
//                    items.append(contentsOf: itemCategory)
//                }
//                
//                var orderItems = [OrderItem]()
//                for item in items {
//                    orderItems.append(OrderItem.init(for: item))
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                
//                let customer = Customer(forNewDocumentIn: self.database.database!)
//                customer.name = "Thinh Lai"
//                customer.mobilephone = "0933918294"
//                customer.address = "Somewhere in Saigon"
//                customer.city = "HCM"
//                customer.state = "Viet Nam"
//                customer.zip = "70000"
//                
//                do {
//                    let order: Order = try Order.new(in: self.database.database!, store: store, shift: shift, employee: employee)
//                    order.id = "17032808302014" // hard code create time
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = printingService.buildPrintItemsData(order: order, items: orderItems, server: employee, settings: settings, type: printItemsType, categories: categories, customer: customer)
//                    let result : Bool = true //printingService.sendToPrinter(printer, data: textPrint)
//                    expect(result) == true
//                } catch _ {
//                    return fail("Could not create Order")
//                }
//            }
//            
//            /// Test check data
//            /// - build string
//            /// - send string to printer
//            it("can build check data") {
//                guard let employee: Employee = self.database.load(storeID, passkey: "11111") else {
//                    return fail("Could not load Employee")
//                }
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//
//                do {
//                    let order: Order = try Order.new(in: self.database.database!, store: store, shift: shift, employee: employee)
//                    order.id = "17032808302014" // hard code create time
//                    let printingBill: Bill = Bill.new(order: order)
//                    order.bills.append(printingBill)
//                    
//                    // Send to printing service
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintCheckData(store: store, order: order, server: employee, printingBill: printingBill)
//                    
//                    let expectedResult = "\n" +
//                        "\n" +
//                        "HCM,  \n" +
//                        "0909117758\n" +
//                        "\n" +
//                        "Server: (Function)\n" +
//                        "03/28/2017      08:30:20\n" +
//                        "\n" +
//                        "Order#: 1 (Bill 1 of 1)\n" +
//                        "              Guests: 01\n" +
//                        "------------------------------------------------\n" +
//                        "------------------------------------------------\n" +
//                        "Subtotal                                   $0.00\n" +
//                        "Total              $0.00\n" +
//                        "------------------------------------------------\n" +
//                        "\n" +
//                        "Thank you!!\n" +
//                        "\n"
//                    
//                    expect(textPrint.string) == expectedResult
//                } catch _ {
//                    return fail("Could not create Order")
//                }
//            }
//            
//            it("can send check data to printer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//
//                
//                guard let employee: Employee = self.database.load(storeID, passkey: "11111") else {
//                    return fail("Could not load Employee")
//                }
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                do {
//                    let order: Order = try Order.new(in: self.database.database!, store: store, shift: shift, employee: employee)
//                    order.id = "17032808302014" // hard code create time
//                    let printingBill: Bill = Bill.new(order: order)
//                    order.bills.append(printingBill)
//                    
//                    // Send to printing service
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintCheckData(store: store, order: order, server: employee, printingBill: printingBill)
//                    let result : Bool = true //printingService.sendToPrinter(printer, data: textPrint)
//                    expect(result) == true
//                } catch _ {
//                    return fail("Could not create Check data")
//                }
//            }
//            
//            /// Test shift and day report
//            /// - build string
//            /// - send string to printer
//            it("can build shift and day report data") {
//                guard let employee: Employee = self.database.load(storeID, passkey: "11111") else {
//                    return fail("Could not load Employee")
//                }
//    
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                // Send to printing service
//                let printingService = ServiceProvider.default.printingService
//                do {
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintShiftAndDayReportData(server: employee, rows: [NameValueReportRow](), date: Date.init(), shift: UInt(shift.index))
//                    let expectedResult = "SHIFT 0 REPORT\n" +
//                        "TrucHeo\n" +
//                        "Apr 17 2017\n" +
//                        "\n" +
//                        "------------------------------------------------\n"
//                    expect(textPrint.string) == expectedResult
//                }catch _ {
//                    return fail("Could not create shift and day report")
//                }
//                
//                
//            }
//            
//            it("can send shift and day report to printer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                guard let employee: Employee = self.database.load(storeID, passkey: "11111") else {
//                    return fail("Could not load Employee")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                do {
//                    // Send to printing service
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintShiftAndDayReportData(server: employee, rows: [NameValueReportRow](), date: Date.init(), shift: UInt(shift.index))
//                    let result : Bool = true //printingService.sendToPrinter(printer, data: textPrint)
//                    expect(result) == true
//                } catch _ {
//                    return fail("Could not create shift and day report")
//                }
//            }
//            
//            /// Test By Payment Type Report
//            /// - build string
//            /// - send string to printer
//            it("can build payment type report data") {
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                // Send to printing service
//                let printingService = ServiceProvider.default.printingService
//                do {
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByPaymentTypeReportData(store: store, date: Date.init(), shift: UInt(shift.index))
//                    let expectedResult = "DETAIL REPORT\n" +
//                        "Apr 17 2017\n" +
//                        "\n"
//                    expect(textPrint.string) == expectedResult
//                }catch _ {
//                    return fail("Could not create payment type report data")
//                }
//            }
//            
//            it("can send payment type report to printer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                do {
//                    // Send to printing service
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByPaymentTypeReportData(store: store, date: Date.init(), shift: UInt(shift.index))
//                    let result : Bool = true //printingService.sendToPrinter(printer, data: textPrint)
//                    expect(result) == true
//                } catch _ {
//                    return fail("Could not create payment type report data")
//                }
//            }
//            
//            /// Test By Payment Type Summary Report
//            /// - build string
//            /// - send string to printer
//            it("can build payment type summary report data") {
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                // Send to printing service
//                let printingService = ServiceProvider.default.printingService
//                do {
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByPaymentTypeSummaryReportData(store: store, date: Date.init(), shift: UInt(shift.index))
//                    let expectedResult = "TOTAL REPORT\n" +
//                        "Apr 17 2017\n" +
//                        "\n"
//                    expect(textPrint.string) == expectedResult
//                }catch _ {
//                    return fail("Could not create payment type summary report data")
//                }
//            }
//            
//            it("can send payment type summary report to printer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                do {
//                    // Send to printing service
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByPaymentTypeSummaryReportData(store: store, date: Date.init(), shift: UInt(shift.index))
//                    let result : Bool = true //printingService.sendToPrinter(printer, data: textPrint)
//                    expect(result) == true
//                } catch _ {
//                    return fail("Could not create payment type summary report data")
//                }
//            }
//            
//            
//            /// Test By Payment Type Server Summary Report
//            /// - build string
//            /// - send string to printer
//            it("can build payment type server summary report data") {
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                // Send to printing service
//                let printingService = ServiceProvider.default.printingService
//                do {
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByServerSummaryReport(store: store, date: Date.init(), shift: UInt(shift.index))
//                    let expectedResult = "SERVER REPORT\n" +
//                        "Apr 17 2017\n" +
//                    "\n"
//                    expect(textPrint.string) == expectedResult
//                }catch _ {
//                    return fail("Could not create payment type server summary report data")
//                }
//            }
//            
//            it("can send payment type server summary report to printer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                do {
//                    // Send to printing service
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByServerSummaryReport(store: store, date: Date.init(), shift: UInt(shift.index))
//                    let result : Bool = true //printingService.sendToPrinter(printer, data: textPrint)
//                    expect(result) == true
//                } catch _ {
//                    return fail("Could not create payment type summary report data")
//                }
//            }
//            
//            
//            /// Test By Payment Type Server Report
//            /// - build string
//            /// - send string to printer
//            it("can build payment type server report data") {
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                // Send to printing service
//                let printingService = ServiceProvider.default.printingService
//                do {
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByServerReport(store: store, date: Date.init(), shift: UInt(shift.index), server: "TrucHeo", serverName: "TrucHeo")
//                    let expectedResult = "SERVER REPORT\n" +
//                        "TrucHeo - Apr 17 2017\n" +
//                    "\n"
//                    expect(textPrint.string) == expectedResult
//                }catch _ {
//                    return fail("Could not create payment type server report data")
//                }
//            }
//            
//            it("can send payment type server report to printer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                guard let store: Store = self.database.load(storeID) else {
//                    return fail("Could not load Store")
//                }
//                
//                let shifts: [Shift] = [Shift(forNewDocumentIn: self.database.database!)]
//                let shift : Shift = shifts.first!
//                shift.id = BaseModel.newID
//                
//                do {
//                    // Send to printing service
//                    let printingService = ServiceProvider.default.printingService
//                    let textPrint : NSMutableAttributedString = try printingService.buildPrintByServerReport(store: store, date: Date.init(), shift: UInt(shift.index), server: "TrucHeo", serverName: "TrucHeo")
//                    let result : Bool = true //printingService.sendToPrinter(printer, data: textPrint)
//                    expect(result) == true
//                } catch _ {
//                    return fail("Could not create payment type summary report data")
//                }
//            }
//            
//            /// Test Open Cash Drawer
//            it("can open cash drawer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                // Send to printing service
//                let printingService = ServiceProvider.default.printingService
//                let result : Bool = true // printingService.sendOpenCashDrawerToPrinter(printer, channel: SCBPeripheralChannel.no1)
//                expect(result) == true
//            }
//            
//            /// Test Play Sound Buzzer
//            it("can play sound buzzer") {
//                let printer : Printer = Printer(forNewDocumentIn: self.database.database!)
//                printer.portSettings = ""
//                printer.portName = "TCP:192.168.1.126"
//                printer.modelName = "TSP143 (STR_T-001)"
//                
//                // Send to printing service
//                let printingService = ServiceProvider.default.printingService
//                let result : Bool = true // printingService.sendPlaySoundBuzzerToPrinter(printer)
//                expect(result) == true
//            }
        }
    }
}
