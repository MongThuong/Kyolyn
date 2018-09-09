//
//  MockDatabase.swift
//  KiolynTests
//
//  Created by Chinh Nguyen on 4/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
@testable import Kiolyn

class MockDatabase: Database {
    func save<T>(_ obj: T) throws where T : MappableBaseModel {
        fatalError()
    }
    
    func load<T>(_ id: String) -> T? where T : MappableBaseModel {
        fatalError()
    }
    
    func async(_ task: @escaping () -> Void) {
        fatalError()
    }
    
    var documentCount: UInt = 0
    
    func deleteCurrentDatabase() {
        fatalError()
    }
    
    func save(properties: [String : Any]) throws {
        fatalError()
    }
    
    func save<T>(_ obj: T) throws where T : BaseModel {
        fatalError()
    }
    
    func save(all objs: [BaseModel]) throws {
        fatalError()
    }
    
    func load(properties docID: String) -> [String : Any]? {
        fatalError()
    }
    
    func load<T>(_ id: String) -> T? where T : BaseModel {
        fatalError()
    }
    
    func load<T>(all storeID: String, byName name: String) -> [T] where T : BaseModel {
        fatalError()
    }
    
    func load<T>(all storeID: String) -> [T] where T : BaseModel {
        fatalError()
    }
    
    func delete<T>(_ obj: T) throws where T : BaseModel {
        fatalError()
    }
    
    func delete<T>(multi objs: [T]) throws where T : BaseModel {
        fatalError()
    }
    
    func load<T>(multi ids: [String]) -> [T?] where T : BaseModel {
        fatalError()
    }
    
    func new<T>(model properties: [String : Any]) -> T? where T : BaseModel {
        fatalError()
    }
    
    func sync(remote storeID: String, passkey: String, mac: String, apiURL: String, syncURL: String) -> Observable<Double> {
        fatalError()
    }
    
    func sync(remote storeID: String, passkey: String, mac: String) -> Observable<Double> {
        fatalError()
    }
    
    func load(station storeID: String, byMacAddress mac: String) -> Station? {
        fatalError()
    }
    
    func load(employee storeID: String, byPasskey passkey: String) -> Employee? {
        fatalError()
    }
    
    func load(defaultDriver storeID: String) -> Employee? {
        fatalError()
    }
    
    func load(drivers storeID: String) -> [Employee] {
        fatalError()
    }
    
    func load(items storeID: String, forCategory category: String) -> [Item] {
        fatalError()
    }
    
    func load(modifiers itemID: String) -> [Modifier] {
        fatalError()
    }
    
    func load(activeShift storeID: String) -> Shift? {
        fatalError()
    }
    
    func count(shifts storeID: String, in day: Date) -> UInt {
        fatalError()
    }
    
    func load(openingOrders storeID: String, forShift shiftID: String, inArea area: Area?, withFilter filter: String) -> [Order] {
        fatalError()
    }
    
    func count(openingOrders storeID: String, forShift shiftID: String) -> UInt {
        fatalError()
    }
    
    func load(orders storeID: String, forShift shiftID: String, matchingStatuses statuses: [OrderStatus], page: UInt, pageSize: UInt) -> QueryResult<Order> {
        fatalError()
    }
    
    func load(customers storeID: String, page: UInt, pageSize: UInt) -> QueryResult<Customer> {
        fatalError()
    }
    
    func load(customers storeID: String, query: (String, String, String, String), limit: UInt) -> [Customer] {
        fatalError()
    }
    
    func load(unsettledTransactions storeID: String, shift shiftID: String, for paymentType: String, page: UInt, pageSize: UInt) -> QueryResult<Transaction> {
        fatalError()
    }
    
    func load(unsettledTransactions storeID: String) -> [Transaction] {
        fatalError()
    }
    
    func count(unsettledTransactions storeID: String, forShift shiftID: String) -> UInt {
        fatalError()
    }
    
    func runBatch(_ block: @escaping () throws -> Void) throws {
        fatalError()
    }
    
    func load(byPaymentTypeReport storeID: String, fromDate: Date, toDate: Date, shift: Int, includeCardType: Bool) -> ReportQueryResult<PaymentTypeTotalReportRow> {
        fatalError()
    }
    
    func load(byPaymentTypeReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<PaymentTypeTotalReportRow>] {
        fatalError()
    }
    
    func load(byAreaReport storeID: String, fromDate: Date, toDate: Date, shift: Int) -> ReportQueryResult<AreaTotalReportRow> {
        fatalError()
    }
    
    func load(byAreaReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<AreaTotalReportRow>] {
        fatalError()
    }
    
    func load(transactions storeID: String, fromDate: Date, toDate: Date, shift: Int, area areaID: String, page: UInt, pageSize: UInt) -> ReportQueryResult<TransactionReportRow> {
        fatalError()
    }
    
    func load(transactions storeID: String, fromDate: Date, toDate: Date, area areaID: String, groupedBy shift: Int) -> [GroupedByShiftQueryResult<Transaction>] {
        fatalError()
    }
    
    func load(byEmployeeReport storeID: String, fromDate: Date, toDate: Date, shift: Int) -> ReportQueryResult<EmployeeTotalReportRow> {
        fatalError()
    }
    
    func load(byEmployeeReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<EmployeeTotalReportRow>] {
        fatalError()
    }
    
    func load(orders storeID: String, ofEmployee emp: String, fromDate: Date, toDate: Date, shift: Int, page: UInt, pageSize: UInt) -> QueryResult<Order> {
        fatalError()
    }
    
    func load(orders storeID: String, ofEmployee emp: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<Order>] {
        fatalError()
    }
    
    func load(shiftSummary storeID: String, fromDate: Date, toDate: Date, shift: Int) -> QuerySummary {
        fatalError()
    }
    
    
}
