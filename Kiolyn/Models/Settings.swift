//
//  Settings.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/9/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Represent an `Area` in system, this `Area` is not meant to be updated but getting from a database sync.
class Settings: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "settings" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "st" }
    
    /// The idle timeout.
    var timeout: Int = 0
    /// All available taxes.
    var taxes: [Tax] = []
    /// All available taxes.
    var discounts: [Discount] = []
    /// All available payment types.
    var paymentTypes: [PaymentType] = []
    /// Sub payment types of Cash.
    var cashSubPaymentTypes: [PaymentType] = []
    /// Sub payment types of Card.
    var cardSubPaymentTypes: [PaymentType] = []
    /// All available group gratuities
    var groupGratuities: [GroupGratuity] = []
    /// Return the tax in percentage to apply to Group Gratuity amount.
    var groupGratuityTax: Double = 0
    /// Return the collection of `Reason`s for voiding group gratuity of an `Order`.
    var voidGroupGratuityReasons: [Reason] = []
    /// Return the collection of category types, order is  matter.
    var categoryTypes: [String] = []
    /// Return the collection of `Reason`s for voiding a `Transaction`.
    var voidTransactionReasons: [Reason] = []
    /// Return the collection of `Reason`s for adjusting `Discount`.
    var discountReasons: [Reason] = []
    /// Return the collection of `Reason`s for voiding `Order`.
    var voidOrderReasons: [Reason] = []
    /// Return the collection of `Reason`s for clocking out.
    var clockoutReasons: [Reason] = []
    /// Return the ordering display settings.
    var ordering = OrderingSettings()

    override func mapping(map: Map) {
        super.mapping(map: map)
        timeout <- map["timeout"]
        taxes <- map["taxes"]
        discounts <- map["discounts"]
        paymentTypes <- map["payment_types"]
        cashSubPaymentTypes <- map["cash_sub_payment_types"]
        cardSubPaymentTypes <- map["card_sub_payment_types"]
        groupGratuities <- map["group_gratuities"]
        groupGratuityTax <- map["group_gratuity_tax"]
        voidGroupGratuityReasons <- map["void_group_gratuity_reasons"]
        categoryTypes <- map["categorytypes"]
        voidTransactionReasons <- map["void_transaction_reasons"]
        discountReasons <- map["discount_reasons"]
        voidOrderReasons <- map["void_order_reasons"]
        clockoutReasons <- map["clockoutreasons"]
        ordering <- map["ordering"]
    }
}

extension Settings {
    /// It is possible that some `Store`s just don't have the `Settings` because the `Settings` logic was implemented after the `Store` creation logic. Thus we need to provide a fallback mechanism to allow old `Store` to have some default `Settings`.
    ///
    /// - Parameter store: The Store to create for.
    /// - Returns: A temporary `Settings` to allow minimum usage of `Store`, this `Settings` is not meant for persistent storage, thus no meta data should be created.
    convenience init(store: Store) {
        self.init(id: "\(Settings.documentIDPrefix)_\(store.id)")
        // NOTE - filling in the default values if needed, so far the default initialization of Settings seem enough
    }
}

/// MARK: - Extra handling for Settings
extension Settings {
    /// Return the first default `Tax`, default Tax is supposed to be single or none, thus we just return the first matched one.
    var defaultTax: Tax? {
        return taxes.first(where: { tax -> Bool in return tax.isDefault })
    }
    /// All available group gratuities sorted by number ascending.
    var sortedGroupGratuities: [GroupGratuity] {
        return groupGratuities.sorted { (lhs, mhs) -> Bool in
            return lhs.number < mhs.number
        }
    }
    /// Find the group gratuity correspond to a number of guests.
    ///
    /// - Parameter numberOfGuest: The number of guest to find the `GroupGratuity` for.
    /// - Returns:
    ///     - `nil`: If there is no group gratuities OR the number of guest is smaller than the smallest number. It means that no group gratuity should be applied
    ///     - The close `GroupGratuity` that has the number of guest bigger than the finding number of guests. For example: There are 2 group gratuities of 10 and 20 guests, finding for 15 will return the 10 one, finding for 25 will return the 20 one.
    func find(groupGratuity numberOfGuest: UInt) -> GroupGratuity? {
        if groupGratuities.count == 0 || numberOfGuest < groupGratuities.first!.number {
            return nil
        } else {
            return groupGratuities.filter{ numberOfGuest >= $0.number }.last
        }
    }
}

/// Service fee based on number of guest
class GroupGratuity: BaseModel {
    /// Minimum number of guest to apply this Service Fee.
    var number: UInt = 0
    /// The service fee to apply in percentage.
    var percent: Double = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        number <- map["number"]
        percent <- map["percent"]
    }
}

/// This class is used to store info of Payment Type and also Sub Payment Type as well, if this payment type contain `subPaymentTypes` then it is a Main Payment Type. Nested level is not limited, however we are using only 1 level only.
class PaymentType: BaseModel {
    var subPaymentTypes: [PaymentType] = []
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        subPaymentTypes <- map["sub_payment_types"]
    }
    
    convenience init(from settings: Settings, with paymentName: String) {
        self.init()
        name = paymentName
        subPaymentTypes = settings.paymentTypes
    }
}

/// Represent the cash payment type.
class EmptySubPaymentType: PaymentType {
    override var name: String {
        get { return "NONE" }
        set {}
    }
}

/// Represent the cash payment type.
class CashPaymentType: PaymentType {
    convenience init(from settings: Settings) {
        self.init()
        name = "CASH"
        subPaymentTypes = settings.cashSubPaymentTypes
    }
}

/// Represent the card payment type.
class CardPaymentType: PaymentType {
    convenience init(from settings: Settings) {
        self.init()
        name = "CREDIT CARD"
        subPaymentTypes = settings.cardSubPaymentTypes
    }
}

/// Multi purpose reason ranging from Voiding item/order/transaction reasons to Clockout reasons.
class Reason: BaseModel {
    /// The time (minutes) for a clockout reason that is payable.
    var payableTime: String = "0000"
    /// True to indicate this is an end of shift clockout reason.
    var endOfShift: Bool = false
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        payableTime <- map["time"]
        endOfShift <- map["end_of_shift"]
    }
}

/// Reason factory
extension Reason {
    /// Return the End of Shift Reason.
    static var endOfShiftReason: Reason {
        let reason = Reason(id: "00000000000000")
        reason.name = "End of shift"
        reason.endOfShift = true
        return reason
    }
}

/// Size of Order Item to be displayed on Order Detail view. This is the size to apply to the `Item`'s name, other text will be relationally displayed to this value.
enum OrderItemSize: String {
    case normal = "normal"
    case big = "big"
    case bigger = "bigger"
}

/// Ordering settings including Items/Categories positions, sizes and Order Detail font size.
class OrderingSettings: BaseModel {
    /// `Item`s grid displaying settings.
    var items = OrderingGridSettings()
    /// `Category`s grid displaying settings.
    var categories = OrderingGridSettings(row: 2)
    /// `Option`s grid displaying settings.
    var options = OrderingGridSettings()
    /// The time (minutes) for a clockout reason that is payable.
    var orderItemSize: OrderItemSize = .normal
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        items <- map["items"]
        categories <- map["categories"]
        options <- map["options"]
        orderItemSize <- (map["orderitem_size"], EnumTransform<OrderItemSize>())
    }
}

/// Contain the settings of how to display Item/Categories/Global Modifier Options as Grid in Ordering View.
class OrderingGridSettings: BaseModel {
    var width: Int = 80
    var height: Int = 80
    var gutter: Int = 8
    var col: Int = 8
    var row: Int = 8
    var fontSize: Int = 16
    var scale: CGFloat = 1.0
    
    var totalWidth: Int { return Int(CGFloat((width + gutter * 2) * col) * scale) }
    var totalHeight: Int { return Int(CGFloat((height + gutter * 2) * row) * scale) }
    
    convenience init(row: Int) {
        self.init(id: "")
        self.row = row
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        width <- map["width"]
        height <- map["height"]
        gutter <- map["gutter"]
        col <- map["col"]
        row <- map["row"]
        fontSize <- map["size"]
    }
}
