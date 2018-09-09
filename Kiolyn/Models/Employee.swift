//
//  Employee.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent an `Employee` in the system, only the most important and used in the system will be mapped.
class Employee : BaseModel {
    /// Document type of this class
    override class var documentType: String { return "employee" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "emp" }
    
    /// Permissions of this employee.
    var permissions = Permissions()
    /// The pay rate of this employee.
    var payrate: Double = 0
    /// If employee is driver
    var isDriver = false
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        permissions <- map["permissions"]
        payrate <- map["payrate"]
        isDriver <- map["delivery_driver"]
        
    }
}

extension Employee {
    /// No driver placeholder employee.
    ///
    /// - Returns: the employee.
    /// - Throws: if there is no database.
    class func noDriver() throws -> Employee {
        let driver = Employee()
        driver.id = "no"
        driver.name = "No Driver"
        return driver
    }
}

/// Employee's permissions.
class Permissions : BaseModel {
    static let REFUND_VOID_UNPAID_SETTLE = "refund_void_unpaid_settle"
    static let CHANGE_ORDER_TAX = "change_order_tax"
    static let DELETE_EDIT_SENT_ITEMS = "delete_edit_sent_items"
    
    /// `True` to indicate that employee can perform Ordering related task.
    var order = false
    /// `True` to indicate that employee can view `Report`s.
    var report = false
    /// `True` to indicate that employee can manage `Customer`s.
    var customer = false
    /// `True` to indicate that employee can change tax of `Order`s.
    var changeOrderTax = false
    /// `True` to indicate that employee can perform advance `Transaction`s tasks.
    var refundVoidUnpaidSettle = false
    /// `True` to indicate that employee can adjust item's price.
    var adjustPrice = false
    /// The maximum discount that employee can apply to `Order`s.
    var maxDiscount: Double = 0
    /// `True` to indicate that employee can edit/delete sent items.
    var deleteEditSentItem = false
    /// `true` for user who must clocked-in before logging in.
    var mustClockin = false
    /// Get max discount percent
    var maxDiscountPercent: Double = 0
    /// Get max discount ammount
    var maxDiscountAmount: Double = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        order <- map["order"]
        report <- map["report"]
        customer <- map["customer"]
        changeOrderTax <- map[Permissions.CHANGE_ORDER_TAX]
        refundVoidUnpaidSettle <- map["refund_void_unpaid_settle"]
        adjustPrice <- map["price_adjustment"]
        maxDiscount <- map["max_discount"]
        deleteEditSentItem <- map["delete_edit_sent_items"]
        mustClockin <- map["must_clockin"]
        maxDiscountPercent <- map["max_discount"]
        maxDiscountAmount <- map["max_discount_amount"]
    }
    
    /// Checking permission by its name
    func has(permission name: String) -> Bool {
        return (toJSON()[name] as? Bool) ?? false
    }
}
