//
//  Order.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Type of order, this value is normally calculated from its ordering `Area`.
///
/// - dineIn: Dine-in.
/// - delivery: Delivery
/// - pickup: Pickup
enum OrderType: String {
    case no = ""
    case dineIn = "DINE-IN"
    case delivery = "DELIVERY"
    case pickup = "PICKUP"
}

/// Order status.
///
/// - new: Just created, can be deleted from the system totally without any worry.
/// - submitted: Submitted to kitchen for making.
/// - printed: Printed (partially/totally) for clients to verify before paying.
/// - checked: Paid (partially/totally).
/// - voided: Voided completely.
enum OrderStatus: String {
    case new = "new"
    case submitted = "submitted"
    case printed = "printed"
    case checked = "checked"
    case voided = "voided"
}

/// Represent an `Order` in the system, this is the most important model in the application, almost all logic are built around this model.
class Order: BaseModel, OrderItemsContainer {
    /// Document type of this class
    override class var documentType: String { return "order" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "ord" }    
    // MARK: ORDER NO/TYPE
    /// Order Number which is sequentially increased and unique inside one shift.
    var orderNo: UInt = 0
    /// The type of Order (DINE-IN, DELIVERY, PICKUP).
    var orderType: OrderType = .no
    // MARK: AREA/TABLE
    /// Order `Area` id.
    var area = ""
    /// Order `Area` name.
    var areaName = ""
    /// Order `Table` id.
    var table = ""
    /// Order `Table` name.
    var tableName = ""
    // MARK: - GUESTS
    /// Number of guests
    var persons: UInt = 0
    // MARK: SHIFT
    /// Shift number.
    var shift: UInt = 0
    /// The `id` of `Shift`.
    var shiftID = ""
    // MARK: SERVICEFEE
    /// The service fee.
    var serviceFee: Double = 0
    /// The service reason.
    var serviceFeeReason = ""
    /// The service fee tax.
    var serviceFeeTax: Double = 0
    // MARK: CUSTOM SERVICE FEE
    /// Holding the true amount (use for calculation)
    var customServiceFeeAmount: Double = 0
    /// Holding the percentage (for displing purpose only)
    var customServiceFeePercent: Double = 0
    // MARK: TAX
    /// The `Tax` to apply to this order.
    var tax: Tax = Tax.noTax
    /// Id of `Employee` who perform a tax removing
    var taxRemovedBy = ""
    // MARK: DISCOUNT
    /// The `Discount` to apply to this order.
    var discount: Discount = Discount.noDiscount
    // MARK: CUSTOMER
    /// The customer (ID) of this order.
    var customer = ""
    /// The customer (Name) of this order.
    var customerName = ""
    /// The customer (Phone) of this order.
    var customerPhone = ""
    /// The customer (Address) of this order.
    var customerAddress = ""
    /// The customer (Email) of this order.
    var customerEmail = ""
    // MARK: DELIVERY
    /// True if this Order is for delivery
    var isDelivery = false
    /// The driver (Employee ID) of this order.
    var driver = ""
    var driverName = ""
    /// The delivered status.
    var delivered = false
    // MARK: CREATING
    /// Employee (ID) who creates this Order.
    var createdBy = ""
    /// Employee (Name) who creates this Order.
    var createdByName = ""
    // MARK: CLOSING
    /// Employee (ID) who closes this Order.
    var closedBy = ""
    /// The time when this Order is closed.
    var closedAt = ""
    /// The type of Order (DINE-IN, DELIVERY, PICKUP).
    var orderStatus: OrderStatus = .new
    // MARK: AMOUNTS
    /// The tip amount.
    var tip: Double = 0
    /// The subtotal amount.
    var subtotal: Double = 0
    /// The total items count.
    var quantity: Double = 0
    /// The calculated tax amount.
    var taxAmount: Double = 0
    /// The calculated discount amount.
    var discountAmount: Double = 0
    /// The calculated service fee amount.
    var serviceFeeAmount: Double = 0
    /// The calculated service fee tax amount.
    var serviceFeeTaxAmount: Double = 0
    /// The total amount.
    var total: Double = 0
    /// The list of `OrderItem`.
    var items: [OrderItem] = []
    /// The list of `Bill`.
    var bills: [Bill] = []

    override func mapping(map: Map) {
        super.mapping(map: map)
        orderNo <- map["order_no"]
        orderType <- (map["order_type"], EnumTransform<OrderType>())
        area <- map["area"]
        areaName <- map["area_name"]
        table <- map["table"]
        tableName <- map["table_name"]
        persons <- map["persons"]
        shift <- map["shift"]
        shiftID <- map["shift_id"]
        serviceFee <- map["service_fee"]
        serviceFeeReason <- map["service_fee_reason"]
        serviceFeeTax <- map["service_fee_tax"]
        customServiceFeeAmount <- map["custom_service_fee_amount"]
        customServiceFeePercent <- map["custom_service_fee_percent"]
        tax <- map["tax"]
        taxRemovedBy <- map["tax_removed_by"]
        discount <- map["discount"]
        customer <- map["customer"]
        customerName <- map["customer_name"]
        customerPhone <- map["customer_phone"]
        customerAddress <- map["customer_address"]
        customerEmail <- map["customer_email"]
        isDelivery <- map["delivery"]
        driver <- map["driver"]
        driverName <- map["driver_name"]
        delivered <- map["delivered"]
        createdBy <- map["created_by"]
        createdByName <- map["created_by_name"]
        closedBy <- map["closed_by"]
        closedAt <- map["closed_at"]
        orderStatus <- (map["status"], EnumTransform<OrderStatus>())
        tip <- map["tip"]
        subtotal <- map["subtotal"]
        quantity <- map["quantity"]
        taxAmount <- map["tax_amount"]
        discountAmount <- map["discount_amount"]
        serviceFeeAmount <- map["service_fee_amount"]
        serviceFeeTaxAmount <- map["service_fee_tax_amount"]
        total <- map["total"]
        items <- map["items"]
        bills <- map["bills"]
    }
}

/// MARK: Status related
extension Order {
    /// Overrides the isNew
    var isNew: Bool { return orderStatus == .new }
    var isNotNew: Bool { return !isNew }
    /// Overrides the isNew
    var isSubmitted: Bool { return orderStatus == .submitted }
    /// `true` if order is either checked or voided.
    var isClosed: Bool { return isVoided || isChecked }
    var isNotClosed: Bool { return !isClosed }
    /// `true` if order is checked.
    var isChecked: Bool { return orderStatus == .checked }
    /// `true` if this order is already printed for checking.
    var isPrinted: Bool { return orderStatus == .printed }
    /// `true` if this order is voided
    var isVoided: Bool { return orderStatus == .voided }
    /// True if there is no items or all items are voided.
    var isEmpty: Bool { return items.isEmpty || !items.contains(where: { $0.isNotVoided }) }
    var isNotEmpty: Bool { return !isEmpty }
    /// `true` if this `Order` is editable.
    var mutable: Bool { return !isClosed && items.count < 99 && total < 1000000.0 }
}

/// MARK: - Customer related
extension Order {
    var hasCustomer: Bool { return customer.isNotEmpty }
    /// For displaying
    var customerSummary: String {
        guard hasCustomer else { return "" }
        var summary = customerName
        if customerEmail.isNotEmpty { summary += ", \(customerEmail)" }
        if customerPhone.isNotEmpty { summary += ", \(customerPhone.formattedPhone)" }
        if customerAddress.isNotEmpty { summary += ", \(customerAddress)" }
        return summary
    }
    /// For Delivery Items
    var customerLine1: String {
        guard hasCustomer else { return "" }
        return "\(customerName) - \(customerPhone.formattedPhone)"
    }
    var customerLine2: String {
        guard hasCustomer else { return "" }
        return customerAddress
    }
    var customerLine3: String {
        guard hasCustomer else { return "" }
        return customerEmail
    }
}

/// MARK: - Delivery related
extension Order {
    var hasDriver: Bool { return driver.isNotEmpty }
    var notDelivered: Bool { return !delivered }
}

/// MARK: - Amounts related
extension Order {
    /// The total amount.
    var totalWithTip: Double { return total + tip }
    
    /// Update all the calculated values base on the Container's inputs.
    func updateCalculatedValues() {
        quantity = items.filter{ $0.status != .voided }.reduce(0.0) { $0 + $1.count }
        subtotal = items.filter{ $0.status != .voided }.reduce(0.0) { $0 + $1.subtotal }
        
        // Given that user is in ordering, when there is a discount in percentage, then:
        if discount.adjustedPercent > 0 {
            // Discount = Subtotal * Discount% ($100 x 20% = $20)
            discountAmount = discount.adjustedPercent * subtotal
        }
        
        // Tax = (Subtotal - Discount) * Tax%  [($100 - $20) x 10% = $8]
        taxAmount = (subtotal - discountAmount) * tax.percent
        
        // Given that user is in ordering, when this is a service fee in percentage, then:
        if customServiceFeePercent > 0 {
            // Service Fee = {[(Subtotal - Discount) + Tax] * Service Fee%}
            customServiceFeeAmount = ((subtotal - discountAmount) + taxAmount) * customServiceFeePercent
        }
        
        // Given that user is in ordering, when this is a group gratuity (GG) in percentage, then:
        // GG = Subtotal * GG%
        serviceFeeAmount = serviceFee * subtotal
        
        // Given that user is in ordering, when this is a group gratuity tax (GG tax) in percentage, then:
        // GG Tax = (Subtotal * GG%) * GG Tax%
        serviceFeeTaxAmount = serviceFeeTax * serviceFeeAmount
        
        // The Final: Total = Subtotal - Discount + Tax + Service Fee + GG + GG Tax
        total = subtotal - discountAmount + taxAmount + customServiceFeeAmount + serviceFeeAmount + serviceFeeTaxAmount
    }
}

/// MARK: - Displaying related
extension Order {
    /// Return opening time in well formatted form.
    var openingTime: String {
        guard id.count >= 9 else { return "--:--" }
        return "\(id[6...7]):\(id[8...9])"
    }
    /// Return opening time in well formatted form.
    var closingTime: String {
        guard closedAt.count >= 9 else { return "--:--" }
        return "\(closedAt[6...7]):\(closedAt[8...9])"
    }
    
    /// Short summary of order.
    var shortSummary: String { return "#\(orderNo) - \(openingTime) - \(bills.count) bill(s)" }
    
    override var debugDescription: String {
        return super.debugDescription + "/#\(orderNo)"
    }
}

extension Order {
    /// Create new Order.
    ///
    /// - Parameters:
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this order.
    ///   - tax: The `Tax` to apply for, default to no tax.
    ///   - discount: The `Discount` to apply for, default to no discount.
    ///   - serviceFeeTax: The service fee tax to apply to service fee (if any).
    ///   - area: The `Area` to create in.
    ///   - table: The `Table` to create for
    /// - Returns: The `Order` object.
    convenience init(inStore store: Store, shift: Shift, employee: Employee, tax: Tax, discount: Discount, serviceFeeTax: Double, area: Area?, table: Table?) {
        self.init()
        // Meta data
        type = Order.documentType
        channels = ["\(Order.documentIDPrefix)_\(store.id)"]
        merchantID = store.merchantID
        storeID = store.id
        // New by default
        orderStatus = .new
        // Creation properties
        createdBy = employee.id
        createdByName = employee.name
        // Number of persons, always default to 1
        persons = 1
        // Area/OrderType information
        if let area = area {
            self.area = area.id
            areaName = area.name
            orderType = area.areaOrderType
        } else {
            orderType = .no
        }
        // Table information
        if let table = table {
            self.table = table.id
            tableName = table.name
        }
        // Shift information
        shiftID = shift.id
        self.shift = shift.index
        // Temporarily set OrderNum here - this OrderNum will be refreshed/reset upon send
        //orderNo = shift.orderNum + 1
        // OrderItems related information
        self.discount = discount
        self.tax = tax
        self.serviceFeeTax = serviceFeeTax
        items = [OrderItem]()
        // Update calculated values right after created
        updateCalculatedValues()
    }
}
