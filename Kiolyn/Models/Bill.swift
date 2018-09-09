//
//  Bill.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Each Order might contain one or more Bill, each Bill has its own Transaction object if it is paid. Bill can be in statuses of NEW, PAIDED, VOIDED.
class Bill: BaseModel, OrderItemsContainer {
    /// True if this is bill is currently voided.
    var voided = false
    /// A `Bill` may be paid/voided more than one time, this object is meant to hold ALL the transactions that were voided after used for paying this `Bill`.
    var voidedTransactions: [String] = []
    /// True if this is bill is already settled.
    var settled = false
    /// Point to the parent bill of this bill, non empty means a splitted bill.
    var parentBill = ""
    /// The total of parent bill.
    var parentTotal: Double = 0
    // MARK: Printing
    /// True if this is bill is alread printed.
    var printed = false
    // MARK: Paid
    /// True if this is bill is already paid.
    var paid = false
    /// Employee (ID) who performs the payment.
    var paidBy = ""
    /// Time when the Bill got paid.
    var paidAt = ""
    /// Type of payment.
    var paymentType = ""
    /// The `Transaction` (ID) that is used to pay for this `Bill`.
    var transaction = ""
    // MARK: OrderItemsContainer
    /// The list of `OrderItem`.
    var items: [OrderItem] = []
    /// The `Tax` to apply to this `Bill`.
    var tax: Tax = Tax.noTax
    /// The `Discount` to apply to this `Bill`.
    var discount: Discount = Discount.noDiscount
    /// The `ServiceFee` percentage to apply for total calculation.
    var serviceFee: Double = 0
    /// The tax to apply to `ServiceFee` amount for total calculation.
    var serviceFeeTax: Double = 0
    /// Each `OrderItem` has its own quantity, this quantity however is the sum of all quantity.
    var quantity: Double = 0
    /// The sum amount of `OrderItem` subtotal.
    var subtotal: Double = 0
    /// The amount in money calculated by applying tax to subtotal.
    var taxAmount: Double = 0
    /// The amount in money calculated by applying discount to subtotal.
    var discountAmount: Double  = 0
    /// The amount in money of service fee applied to this container.
    var serviceFeeAmount: Double = 0
    /// The amount in money of service fee tax applied to this container.
    var serviceFeeTaxAmount: Double = 0
    /// The percentage of custom service fee used for displaying purpose.
    var customServiceFeeAmount: Double = 0
    /// The amount of custom service fee used for subtotal calculation.
    var customServiceFeePercent: Double = 0
    /// The final amount of this container.
    var total: Double = 0
    /// The tip amount of this container.
    var tip: Double = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        voided <- map["voided"]
        voidedTransactions <- map["voided_transactions"]
        settled <- map["settled"]
        parentBill <- map["parent_bill"]
        parentTotal <- map["parent_total"]
        printed <- map["printed"]
        paid <- map["paid"]
        paidBy <- map["paid_by"]
        paidAt <- map["paid_at"]
        paymentType <- map["payment_type"]
        transaction <- map["transaction"]
        items <- map["items"]
        total <- map["service_fee_amount"]
        tax <- map["tax"]
        discount <- map["discount"]
        serviceFee <- map["service_fee"]
        serviceFeeTax <- map["service_fee_tax"]
        quantity <- map["quantity"]
        subtotal <- map["subtotal"]
        taxAmount <- map["tax_amount"]
        discountAmount <- map["service_fee_amount"]
        serviceFeeAmount <- map["service_fee_amount"]
        serviceFeeTaxAmount <- map["service_fee_tax_amount"]
        customServiceFeeAmount <- map["custom_service_fee_amount"]
        customServiceFeePercent <- map["custom_service_fee_percent"]
        total <- map["total"]
        tip <- map["tip"]
    }
}

// MARK: - Creation related
extension Bill {
    /// Create empty bill for a given Order.
    ///
    /// - Parameter order: The `Order` to create bill for.
    convenience init(order: Order) {
        self.init()
        tax = Tax(JSON: order.tax.toJSON())!
        discount = Discount(JSON: order.discount.toJSON())!
        serviceFee = order.serviceFee
        serviceFeeTax = order.serviceFeeTax
        customServiceFeeAmount = order.customServiceFeeAmount
        customServiceFeePercent = order.customServiceFeePercent
        updateCalculatedValues()
    }
}

// MARK: - Status related
extension Bill {
    /// Bill is splittable if it is not yet paid and the total quantity is more than 1.
    var splittable: Bool { return !paid && quantity > 0 }
    var isSplitted: Bool { return parentBill.isNotEmpty }
    var isNotSplitted: Bool { return parentBill.isEmpty }
    var notPrinted: Bool { return !printed }
    var isNotPaid: Bool { return !paid }
    /// Bill is payable if it is not yet Paid and there are items to pay for.
    var payable: Bool { return !paid && items.count > 0 }
}

// MARK: - Amount calculating related
extension Bill {
    /// The total + tip amount of this container.
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


// MARK: - Bill merging/splitting.
extension Bill {
    
    /// Split this bill to a new bill with given amount and id
    ///
    /// - Parameters:
    ///   - amount: The amount to split.
    ///   - id: The new bill id.
    func split(amount: Double, with newid: String = BaseModel.newID) -> Bill {
        let newBill = Bill(JSON: toJSON())!
        newBill.id = newid
        newBill.parentBill = isSplitted ? parentBill : id
        newBill.parentTotal = isSplitted ? parentTotal : total
        newBill.total = amount
        return newBill
    }
    
    /// Convert bill from unsplit to split with given amount.
    ///
    /// - Parameter amount: The amount to split.
    func convert(toSplit amount: Double) {
        if isNotSplitted {
            parentBill = id
            parentTotal = total
        }
        total = amount
    }
    
    /// Convert a bill from split to unsplit.
    func unsplit() {
        total = parentTotal
        parentBill = ""
        parentTotal = 0
    }

    /// Convert this bill into a split bill
    ///
    /// - Parameter amount: The new amount.
    func toSplit(amount: Double) {
        if isNotSplitted {
            parentBill = id
            parentTotal = total
        }
        total = amount
    }

    /// Add more `OrderItem`s to this build due to a result of merging/removing Bill.
    ///
    /// - Parameter items: The `OrderItem`s to be added
    func add(items: [OrderItem]) {
        guard items.isNotEmpty else { return }
        for item in items {
            // Find a target item which has the same ID (merged items that was splitted)
            if let toItem = self.items.first(where: { $0.id == item.id }) {
                // Increase the count value of existing target item
                toItem.count += item.count
                toItem.updateCalculatedValues()
            } else {
                // No new target item, so move the whole item over
                self.items.append(item)
            }
        }
        updateCalculatedValues()
    }
}
