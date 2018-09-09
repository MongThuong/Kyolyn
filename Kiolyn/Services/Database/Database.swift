//
//  Database.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/3/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Errors thrown by database related activities.
enum DatabaseError: LocalizedError {
    case couldNotOpenOrCreateDatabase(name: String)
    case couldNotGetNorCreateDocument(id: String)
    case couldNotSaveDocument(error: Error)
    case couldNotDeleteDocument(error: Error)
    case missingMeta(field: String)
    case errorCreatingModel(id: String, message: String)
    
    var errorDescription: String? {
        switch self {
        case let .couldNotOpenOrCreateDatabase(name):
            return "Could not open or create database with name \(name)"
        case let .couldNotGetNorCreateDocument(id):
            return "Could not get or create document with id \(id)"
        case let .couldNotSaveDocument(error):
            return "Could not save document \(error.localizedDescription)"
        case let .couldNotDeleteDocument(error):
            return "Could not delete document \(error.localizedDescription)"
        case let .missingMeta(field):
            return "Missing required meta field '\(field)'"
        case let .errorCreatingModel(id, message):
            return "Could not create model with id \(id): \(message)"
        }
    }
}

/// List of all types that can be updated/created and sync to server - used as a push filter.
/// 1. ORDER/SHIFT/TRANSACTION/CUSTOMER are data created on the client.
/// 2. PRINTER/STATION/CCDEVICE are updated to reflect the IP address.
/// 3. SETTINGS for updating TransNumber.
let databasePushableObjectTypes = [Order.documentType, Printer.documentType, Transaction.documentType, Customer.documentType, Shift.documentType, Station.documentType, CCDevice.documentType, TimeCard.documentType]

/// List of all types that are can be mutated locally, this is just as a prevention, just in case there are unwanted saves.
let databaseMutableObjectTypes = [Store.documentType] + databasePushableObjectTypes


/// Database protocol 
protocol Database {
    
    // MARK: - Generic
    
    /// Return the total number of document inside the database.
    var documentCount: UInt { get }
    
    /// Delete the current database
    func deleteCurrentDatabase()
    
    /// Save an object using `[String: Any]` as the sole parameter. The data must contain `id`, `type`, `merchantid` at the minimum. For object type that must be pushed to server, the `channels` property must exist also.
    ///
    /// - Parameter properties: The key/value list of the object.
    /// - Throws: `DatabaseError` if there is error saving to database.
    func save(properties: [String: Any]) throws -> String
    
    /// Save multiple properties.
    ///
    /// - Parameter properties: the list of properties to be saved
    /// - Returns: the list of new revisions
    /// - Throws: `DatabaseError` if there is error saving to database.
    func save(properties: [[String: Any]]) throws -> [String]
    
    /// Save multiple objects.
    ///
    /// - Parameter obj: the object to save.
    /// - Throws: any error thrown by CBL.
    func save(_ obj: BaseModel) throws
    
    /// Save multiple objects.
    ///
    /// - Parameter objs: the objects to save.
    /// - Throws: any error thrown by CBL.
    func save(all objs: [BaseModel]) throws
    
    /// Load properties of a document using its id.
    ///
    /// - Parameter docID: the document id.
    /// - Returns: the properties of loaded document.
    func load(properties docID: String) -> [String: Any]?
    
    /// Load object using its id, the object type is based on the given type. The document id is calcuated as `type`_`id`. The object must be registered with datbase's domain model.
    ///
    /// - Parameter id: Object id, not the document id.
    /// - Returns: The object of type `T` with matched `id`.
    func load<T:BaseModel>(_ id: String) -> T?
    
    /// Load all objects of the given type for the given `Store` which has the given name.
    ///
    /// - Parameters:
    ///   - storeID: The `id` of the `Store` to load for.
    ///   - name: The `name` of the object to load for.
    /// - Returns: List of object that have the given name
    func load<T:BaseModel>(all storeID: String, byName name: String) -> [T]
    
    /// Load all object of given type that belongs to a store.
    ///
    /// - Parameter storeID: the store to load for.
    /// - Returns: list of object of given type.
    func load<T:BaseModel>(all storeID: String) -> [T]
    
    /// Load list of properties of given type that belongs to a given store.
    ///
    /// - Parameters:
    ///   - storeID: the store to load for.
    ///   - type: the type to load for.
    ///   - name: the name filtering.
    /// - Returns: list of loaded properties.
    func loadProperties(all storeID: String, for type: BaseModel.Type, byName name: String) -> [[String: Any]]
    
    /// Delete objects from databaes.
    ///
    /// - Parameter objs: the list of objects to be deleted.
    /// - Throws: `DatabaseError` if there is error saving to database.
    func delete<T: BaseModel>(multi objs: [T]) throws
    
    /// Delete an object.
    ///
    /// - Parameter obj: the object to be deleted.
    /// - Throws: if not found.
    func delete<T: BaseModel>(_ obj: T) throws
    
    /// Delete a document by its id.
    ///
    /// - Parameter docID: the document id to delete for.
    /// - Throws: if not found.
    func delete(_ docID: String) throws
    
    /// Load multiple object using their ids.
    ///
    /// - Parameter ids: the list of ids to load for.
    /// - Returns: the list of object.
    func load<T: BaseModel>(multi ids: [String]) -> [T?]
    
    /// Load properties for multiple objects.
    ///
    /// - Parameters:
    ///   - ids: the list of of ids to load for.
    ///   - type: the type to load for
    /// - Returns: the list of properties of loaded ids.
    func loadProperties(multi ids: [String], for type: BaseModel.Type) -> [[String: Any]?]
    func loadProperties(multi ids: [String]) -> [[String: Any]?]
    
    // MARK: - Remote Sync
    
    /// Get a sync session ID then save it a `Store` object then start syncing process. This method should be called by Remote Sync function like Sync button on Login screen.
    ///
    /// - Parameters:
    ///   - storeID: The `id` of the `Store`.
    ///   - passkey: The `passkey` that will be used to identified the current user.
    ///   - mac: The `mac` address of the running iPad.
    ///   - apiURL: The API root URL, default to whatever inside the apiRootURL.
    ///   - syncURL: The sync gateway root URL, default to whatever inside the syncRootURL.
    /// - Returns: The sync progress observable.
    func sync(remote storeID: String, passkey: String, mac: String, apiURL: String, syncURL: String) -> Observable<Double>
    func sync(remote storeID: String, passkey: String, mac: String) -> Observable<Double>
    
    // MARK: - Station
    
    /// Load a single station base on its MAC address.
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - mac: The station's MAC address to load for.
    /// - Returns: The `Station` or `nil` if not found.
    func load(station storeID: String, byMacAddress mac: String) -> Station?
    func loadStation(properties storeID: String, byMacAddress mac: String) -> [String: Any]?
    
    // MARK: - Employee
    
    /// Load a single employee base on its passkey/
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - passkey: The employee's passkey to load for.
    /// - Returns: The `Employee` or `nil` if not found.
    func load(employee storeID: String, byPasskey passkey: String) -> Employee?
    
    /// Load the default driver for delivery area.
    ///
    /// - Parameter storeID: the `Store` to load from.
    /// - Returns: the default of `Driver` of the given `Store`.
    func load(defaultDriver storeID: String) -> Employee?
    func loadProperties(defaultDriver storeID: String) -> [String: Any]?
    
    /// Load all drivers.
    ///
    /// - Parameter storeID: the `Store` to load from.
    /// - Returns: the list of `Driver`s of the given `Store`.
    func load(drivers storeID: String) -> [Employee]
    func loadProperties(drivers storeID: String) -> [[String: Any]]
        
    // MARK: - Menu
    
    /// Load all items (excluding the hidden ones) for a given store that belongs to given category.
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - category: The `Category` to load for.
    /// - Returns: All `Item`s belong to the given `Category`.
    func load(items storeID: String, forCategory category: String) -> [Item]
    func loadProperties(items storeID: String, forCategory category: String) -> [[String: Any]]
    
    /// Load all modifiers (excluding the hidden ones) for a given store that belongs to given item.
    ///
    /// - Parameters:
    ///   - storeID: The store to load from.
    ///   - item: The `Item` to load for.
    /// - Returns: All `Modifier`s belong to the given `Category`.
    func load(modifiers itemID: String) -> [Modifier]
    func loadProperties(modifiers itemsID: String) -> [[String: Any]]
    
    /// Load all global modifiers for a given store.
    ///
    /// - Parameter storeID: the Store to load for.
    /// - Returns: All `Mofifier`s belong to a store.
    func load(globalModifiers storeID: String) -> [Modifier]
    func loadProperties(globalModifiers storeID: String) -> [[String: Any]]
    
    // MARK: - Shift
    
    /// Return the currently opening shift.
    ///
    /// - Parameter storeID: The store to open for.
    /// - Returns: current active `Shift` or nil of none is being opened.
    func load(activeShift storeID: String) -> Shift?
    func loadProperties(activeShift storeID: String) -> [String: Any]?
    
    /// Return the total shift in a single day.
    ///
    /// - Parameters:
    ///   - storeID: The store to count for.
    ///   - day: The day to count for.
    /// - Returns: The shift count in given day.
    func count(shifts storeID: String, in day: Date) -> UInt
        
    // MARK: - Order
    
    /// Load open orders for Store/Shift/Area with filtering.
    ///
    /// - Parameters:
    ///   - storeID: the store to load for.
    ///   - shiftID: the shift to load for.
    ///   - area: the area to load for.
    ///   - filter: the filter to be applied.
    /// - Returns: List of orders.
    func load(openingOrders storeID: String, forShift shiftID: String, inArea area: Area?, withFilter filter: String) -> [Order]
    func loadProperties(openingOrders storeID: String, forShift shiftID: String, inArea area: Area?, withFilter filter: String) -> [[String: Any]]
    
    /// Return the number of sumbitted orders (opening) for a given store.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    /// - Returns: Number of opening `Order`s.
    func count(openingOrders storeID: String, forShift shiftID: String) -> UInt
    
    /// Load orders by given statuses.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    ///   - statuses: List of `OrderStatus`es to load for.
    ///   - page: The page to load for.
    ///   - pageSize: The page size to load for.
    /// - Returns: `Order`s that matches the loading conditions with its summary.
    func load(orders storeID: String, forShift shiftID: String, matchingStatuses statuses: [OrderStatus], page: UInt, pageSize: UInt) -> QueryResult<Order>
    func loadProperties(orders storeID: String, forShift shiftID: String, matchingStatuses statuses: [OrderStatus], page: UInt, pageSize: UInt) -> [String: Any]

    // MARK: - Customer
    
    /// Load customer with pagination support.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - page: Number of record to return.
    ///   - pageSize: Number of record to skip.
    /// - Returns: QueryResult of `Customer`s that matches the loading conditions.
    func load(customers storeID: String, page: UInt, pageSize: UInt) -> QueryResult<Customer>
    
    /// Find customers based on combination of Name, Phone, Email, Address.
    ///
    /// - Parameters:
    ///   - storeID: The Store to search in.
    ///   - query: The customer info to search for.
    ///   - limit: The limit of returned result.
    /// - Returns: The list of matched customers.
    func load(customers storeID: String, query: (String, String, String, String), limit: UInt) -> [Customer]
    func loadProperties(customers storeID: String, query: (String, String, String, String), limit: UInt) -> [[String: Any]]
    
    // MARK: - Transaction
    
    /// Load unsettled transactions.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    ///   - paymentType: The `PaymentType` tot load for
    ///   - page: Number of record to return.
    ///   - pageSize: Number of record to skip.
    /// - Returns: `Transaction`s that matches the loading conditions with its summary.
    func load(unsettledTransactions storeID: String, shift shiftID: String, for paymentType: String, page: UInt, pageSize: UInt) -> QueryResult<Transaction>
    
    /// Load ALL unsettled transactions.
    ///
    /// - Parameter storeID: the `Store` to load for.
    /// - Returns: List of unsettled transactions.
    func load(unsettledTransactions storeID: String) -> [Transaction]
    
    /// Count the unsettled transactions.
    ///
    /// - Parameters:
    ///   - storeID: The `Store` to load for.
    ///   - shiftID: The `Shift` to load for.
    /// - Returns: Number of unsettled transactions.
    func count(unsettledTransactions storeID: String, forShift shiftID: String) -> UInt 
    
    // MARK: - Async
    
    /// Do async database access
    ///
    /// - Parameter task: async access.
    func async(_ task: @escaping () -> Void)
    
    /// Run atomic block inside a transaction.
    ///
    /// - Parameter block: The block to perform, return `true` for having all updates settled, `false` for rolling back.
    /// - Throws: any error thown by the running block.
    func runBatch(_ block: @escaping () throws -> Void) throws
    
    
    // MARK: - Reports
    
    /// Load `Transaction`s summary by type (Cash, Credit Card).
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    ///   - includeCardType: return with card type.
    /// - Returns: Report query result with ros as payment type total
    func load(byPaymentTypeReport storeID: String, fromDate: Date, toDate: Date, shift: Int, includeCardType: Bool) -> ReportQueryResult<PaymentTypeTotalReportRow>
    
    /// Load `Transaction`s summary by payment type (Cash, Credit Card) and grouped by shift
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    /// - Returns: The list of `QueryResult` of `ByPaymentTypeReportRow`, each corresponde to a single shift.
    func load(byPaymentTypeReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<PaymentTypeTotalReportRow>]
    
    /// Load `Orders`s summary by Area.
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    /// - Returns: The `QueryResult` of `AreaTotalReportRow`.
    func load(byAreaReport storeID: String, fromDate: Date, toDate: Date, shift: Int) -> ReportQueryResult<AreaTotalReportRow>
    
    /// Load `Orders`s summary by Area (Cash, Credit Card) and grouped by shift
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    /// - Returns: The list of `QueryResult` of `AreaTotalReportRow`, each corresponde to a single shift.
    func load(byAreaReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<AreaTotalReportRow>]
    
    /// Load `Transaction`s based on payment type (Cash, Credit Card)
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    ///   - areaID: The area to load for.
    ///   - page: The page to load for.
    ///   - pageSize: The number of record per page.
    /// - Returns: The `QueryResult` of `Transaction`.
    func load(transactions storeID: String, fromDate: Date, toDate: Date, shift: Int, area areaID: String, page: UInt, pageSize: UInt) -> ReportQueryResult<TransactionReportRow>
    
    /// Load `Transaction`s by payment type (Cash, Credit Card) and grouped by shift.
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - from: The start date to load for.
    ///   - to: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    ///   - area: The area to load for (optional). empty means all.
    /// - Returns: The list of `QueryResult` of `Transaction`, each corresponde to a single shift.
    func load(transactions storeID: String, fromDate: Date, toDate: Date, area areaID: String, groupedBy shift: Int) -> [GroupedByShiftQueryResult<Transaction>]
    
    /// Load `Order`s summary by server.
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    /// - Returns: The `QueryResult` of `ByPaymentTypeReportRow`.
    func load(byEmployeeReport storeID: String, fromDate: Date, toDate: Date, shift: Int) -> ReportQueryResult<EmployeeTotalReportRow>
    
    /// Load `Order`s summary by employee.
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - shift: The shift to load for (optional). 0 means all.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    /// - Returns: The list of `QueryResult` of `ByPaymentTypeReportRow`, each corresponde to a single shift.
    func load(byEmployeeReport storeID: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<EmployeeTotalReportRow>] 

    /// Load `Order`s by server.
    ///
    /// - Parameters:
    ///   - storeID: the `Store`'s ID to load for.
    ///   - server: the `Employee` to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for.
    ///   - shift: The shift to load for, 0 means all.
    ///   - page: The page to load for.
    ///   - pageSize: The number of record per page.
    /// - Returns: The `QueryResult` of `Order`.
    func load(orders storeID: String, ofEmployee emp: String, fromDate: Date, toDate: Date, shift: Int, page: UInt, pageSize: UInt) -> QueryResult<Order>
    
    /// Load `Order`s by server and grouped by shift.
    ///
    /// - Parameters:
    ///   - storeID: the `Store`'s ID to load for.
    ///   - server: the `Employee` to load for.
    ///   - shift: The shift to load for (optional). 0 means all.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    /// - Returns: The `QueryResult` of `Order`.
    func load(orders storeID: String, ofEmployee emp: String, fromDate: Date, toDate: Date, groupedBy shift: Int) -> [GroupedByShiftQueryResult<Order>]

    /// Load Orders summary by shift and day.
    ///
    /// - Parameters:
    ///   - storeID: The `Store`'s ID to load for.
    ///   - fromDate: The start date to load for.
    ///   - toDate: The to date to load for (optional). Nil mean load only for `fromDate`.
    ///   - shift: The shift to load for (optional). 0 means all.
    /// - Returns: The `QuerySummary` of `Order` with given parameters.
    func load(shiftSummary storeID: String, fromDate: Date, toDate: Date, shift: Int) -> QuerySummary 
}



