//
//  OrderItemsContainer.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// Represent a container for `OrderItem`, so far only `Order`, `Bill` conforms to this protocol.
protocol OrderItemsContainer {
    /// The list of `OrderItem`.
    var items: [OrderItem] { get }
    /// The `Tax` to apply for total calculation.
    var tax: Tax { get }
    /// The `Discount` to apply for total calculation.
    var discount: Discount { get }
    /// The `ServiceFee` percentage to apply for total calculation.
    var serviceFee: Double { get }
    /// The tax to apply to `ServiceFee` amount for total calculation.
    var serviceFeeTax: Double { get }
    /// Each `OrderItem` has its own quantity, this quantity however is the sum of all quantity.
    var quantity: Double { get set }
    /// The sum amount of `OrderItem` subtotal.
    var subtotal: Double { get set }
    /// The amount in money calculated by applying tax to subtotal.
    var taxAmount: Double { get set }
    /// The amount in money calculated by applying discount to subtotal.
    var discountAmount: Double { get set }
    /// The amount in money of service fee applied to this container.
    var serviceFeeAmount: Double { get set }
    /// The amount in money of service fee tax applied to this container.
    var serviceFeeTaxAmount: Double { get set }
    /// The percentage of custom service fee.
    var customServiceFeePercent: Double { get set }
    /// The amount of custom service fee.
    var customServiceFeeAmount: Double { get set }
    /// The final amount of this container.
    var total: Double { get set }
    /// The tip amount of this container.
    var tip: Double { get set }
    /// The total + tip amount of this container.
    var totalWithTip: Double { get }
}
