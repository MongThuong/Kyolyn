//
//  OrderItem.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Status of `OrderItem`.
///
/// - voided: `OrderItem` is voided, should not be included in any calculation.
/// - new: `OrderItem` is newly added to `Order`.
/// - submitted: `OrderItem` has been sent to kitchen.
/// - checked: `OrderItem` has been printed/checked completely or partially.
/// - paid: `OrderItem` has been printed/checked completely or partially.
enum OrderItemStatus: String {
    case voided = "void"
    case new = "new"
    case submitted = "submitted"
    case checked = "printed"
    case paid = "checked"
    
    static func from(_ value: Any?) -> OrderItemStatus {
        guard let rawValue = value as? String else { return .new }
        return OrderItemStatus(rawValue: rawValue) ?? .new
    }
}

/// Represent an `Item` inside an `Order`.
class OrderItem: BaseModel {
    /// The Category (id) that this Order Item is created from.
    var categoryID = ""
    /// The Item (id) that this Order Item is created from.
    var itemID = ""
    /// The Name2 of the Item that this Order Item is created from.
    var name2 = ""
    /// The Name2 language of the Item that this Order Item is created from.
    var name2Language = ""
    /// The price of this Order Item, most of the time it is the same price of the Item that this Order Item is created upon. But it is the value input by user when it is an Open Item.
    var price: Double = 0
    /// The hex color string copied from `Item`.
    var color = "#ffffff"
    /// True if this order item is created as open item from a `Category` that supports open item.
    var isOpenItem = false
    var isNotOpenItem: Bool { return !isOpenItem }
    /// Contain the list of printers ids - this is used by Open Item to contains user selection of the printers.
    var printers: [BaseModel] = []
    /// The hex color string copied from `Item`.
    var image: Image?
    /// True if this item is a ToGo one.
    var togo = false
    var notTogo: Bool { return !togo }
    /// True if this item is a Hold one.
    var hold = false
    var notHold: Bool { return !hold }
    /// True if this item is a Hold one.
    var count: Double = 0
    /// Extra Note to be sent to Kitchen.
    var note = ""
    /// The price of Note, this is for input option that is not registed in the the system.
    var priceNote: Double = 0
    /// Keep the Modifiers of this Order Item and their Options.
    var modifiers: [OrderModifier] = []
    /// Return the already billed count, should be equal or less than the Count.
    var billedCount: Double = 0
    /// Return the already paided count, should be equal or less than the Count.
    var paidCount: Double = 0
    /// Return the already paided count, should be equal or less than the Count.
    var voidReason = ""
    /// Status of an Order Item.
    /// Eventhough this object can be contained in either Order or Bill.
    /// Only the Status in Order make sense, Status in Bill is controlled by the Bill itself.
    /// And it has only 2 statuses Paid and Unpaid.
    var status: OrderItemStatus = .new
    /// True if this item is submitted and edited.
    var isUpdated = false
    /// The Total amount of this Order Item taking into consideration ALL the accountable amount.
    var subtotal: Double = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        categoryID <- map["categoryid"]
        itemID <- map["itemid"]
        name2 <- map["name2"]
        name2Language <- map["name2_lang"]
        price <- map["price"]
        color <- map["color"]
        isOpenItem <- map["open_item"]
        printers <- map["printers"]
        image <- map["image"]
        togo <- map["togo"]
        hold <- map["hold"]
        count <- map["count"]
        note <- map["note"]
        priceNote <- map["price_note"]
        modifiers <- map["modifiers"]
        billedCount <- map["billed_count"]
        paidCount <- map["paid_count"]
        voidReason <- map["void_reason"]
        status <- (map["status"], EnumTransform<OrderItemStatus>())
        isUpdated <- map["isupdated"]
        subtotal <- map["subtotal"]
    }
    
    /// Create from an Item, this should be called when an `Item` is selected from the Ordering screen.
    ///
    /// - Parameter item: The `Item` to add to `Order`.
    convenience init(for item: Item) {
        self.init()
        name = item.name // Copy name over
        price = item.price
        name2 = item.name2
        name2Language = item.name2Language
        categoryID = item.category // Copy category id (mostly for reporting)
        count = 1 // 1 by newly added
        status = .new // new by default
        color = item.color
        if color.isEmpty {
            color = name.hexColor
        }
        if item.isOpenItem { // Open Item specific logic
            itemID = BaseModel.newID // Create new id for open item every time it is added
            isOpenItem = true
        } else {
            itemID = item.id // Copy the item id over
            image = item.image // No need for a clone here becaus swift's dictionary is struct, and inner values of images are NOT objects.
        }
        // first update
        updateCalculatedValues()
    }
}

// MARK: - Statuses
extension OrderItem {
    var isNew: Bool { return status == .new }
    var isNotNew: Bool { return !isNew }
    var isVoided: Bool { return status == .voided }
    var isNotVoided: Bool { return !isVoided }
    var isPaid: Bool { return status == .paid }
    var isNotPaid: Bool { return !isPaid }
    var isSubmitted: Bool { return status == .submitted }
    var isChecked: Bool { return status == .checked }
    
    /// True if this item is billed somehow.
    var isBilled: Bool { return !isPaid && billedCount > 0 }
    var isNotBilled: Bool { return !isBilled }
    
    /// `true` if note exists.
    var hasNote: Bool { return priceNote > 0 || note.isNotEmpty }
    var hasVoidReason: Bool { return self.voidReason.isNotEmpty }
}

extension OrderItem {
    /// `true` if there is modifier.
    var hasModifiers: Bool { return modifiers.isNotEmpty }
    
    /// Build the flat list of Modifier's options, mostly for displaying and printing.
    var options: [(String, Double)] {
        return modifiers
            .filter { $0.isNotSameline && $0.hasOption }
            .flatMap { modifier -> [(String, Double)] in
                modifier.options.map { ($0.name, ($0.price*self.count).roundM()) }
        }
    }
    
    /// The count of flat options of this order item.
    var optionCount: Int {
        return modifiers.reduce(0, { (total, om) -> Int in
            return total + om.options.count
        })
    }
}

// MARK: - Calculated values
extension OrderItem {
    /// Return this Order Item total amout without Modifiers/Options calculated. For displaying as SubTotal on Order Detail.
    var noModifierSubtotal: Double { return (price * count).roundM() }
    
    /// Returns the total amount of Note considering the Count.
    var noteSubtotal: Double { return (priceNote * count).roundM() }
    
    /// Update calculated values based on dependencies changes. We need to round up here.
    func updateCalculatedValues() {
        // Modifiers/Options
        let modTotal = modifiers.reduce(0.0) { (itemTotal, mod) -> Double in
            return mod.options.reduce(itemTotal, { (modTotal, option) -> Double in
                return modTotal + (option.price * count).roundM()
            })
        };
        // Total with subtotal, note subtotal, modifier subtotal
        subtotal = noModifierSubtotal + modTotal + noteSubtotal;
    }
}

// MARK: - Cloning
extension OrderItem {
    /// Clone for billing.
    var billItem: OrderItem {
        return self.clone(without: ["status", "billed_count", "paid_count", "hold", "togo"])
    }
}

// MARK: - Sameline
extension OrderItem {
    
    /// Return the total of all the sameline modifier options.
    var samelineSubtotal: Double {
        return noModifierSubtotal + modifiers.reduce(0) { (r, om) -> Double in
            // reduce only the sameline ones
            guard om.isSameline else { return r }
            // sum all the value of options to the final total
            return om.options.reduce(r) { (r, o) -> Double in
                return r + (o.price * count).roundM()
            }
        }
    }
    
    /// Return a join of all the options from all sameline modifiers.
    var samelineOptions: String {
        return modifiers
            .filter { $0.isSameline }
            .flatMap { om -> [Option] in om.options }
            .map { $0.name }
            .joined(separator: " ")
    }
    
    /// Return the name with same line modifiers.
    var samelineName: String { return "\(name) \(samelineOptions)" }
    
    /// Return the name with same line modifiers.
    var samelineName2: String { return "\(name2) \(samelineOptions)" }
}

