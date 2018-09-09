//
//  KichenPrintingSettings.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/20/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

class PrintingSettings: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "printtpl" }
    
    required init() {
        super.init(id: "")
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
}

/// Contain all the settings for kitchen receipt printing. This is common settings for all kind of kitchen printing including Send, Resend, Void.
class KitchenPrintingSettings: PrintingSettings {
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "ptl_kitchen" }

    /// True if date should be printed.
    var printDate = true
    /// True if time should be printed.
    var printTime = true
    /// True if table number should be printed.
    var printTableNo = true
    /// True if number of guest should be printed.
    var printNoOfGuest = true
    /// True if server name should be printed.
    var printServerName = true
    /// True if transaction should be printed.
    var printTransaction = true
    /// True if modifiers should be printed.
    var printModifier = true
    /// True if note name should be printed.
    var printNote = true
    /// True if item should be grouped by categories for printing.
    var printGrouping = true
    /// True if item name should be printed.
    var printItemsName1 = true
    /// True if item name 2 should be printed.
    var printItemsName2 = true
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        printDate <- map["print_date"]
        printTime <- map["print_time"]
        printTableNo <- map["print_table_no"]
        printNoOfGuest <- map["print_no_of_guest"]
        printServerName <- map["print_server_name"]
        printTransaction <- map["print_transaction"]
        printModifier <- map["print_modifier"]
        printNote <- map["print_note"]
        printGrouping <- map["print_grouping"]
        printItemsName1 <- map["print_items_name_1"]
        printItemsName2 <- map["print_items_name_2"]
    }
}


/// Contain the tip guide.
class TipGuide: BaseModel {
    /// The percent of this tip guide.
    var percent: Double = 0
    
    convenience init(percent: Double) {
        self.init(id: "")
        self.percent = percent
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        percent <- map["percent"]
    }
}

fileprivate let defaultTips = [ TipGuide(percent: 0.15), TipGuide(percent: 0.18), TipGuide(percent: 0.2) ]

/// Contain all the settings for check receipt printing. This is common settings for all kind of kitchen printing including Send, Resend, Void.
class CheckReceiptPrintingSettings: PrintingSettings {
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "ptl_check_receipt" }

    var printLogo = true
    var printStoreName = true
    var printAddress = true
    var printPhone = true
    var printTableNo = true
    var printOrderNo = true
    var printNoOfGuest = true
    var printDateTime = true
    var printTransactionNo = true
    var printServerName = true
    var printItemsName1 = true
    var printItemsName2 = true
    var printCustomerInfo = true
    var printTipGuide = true
    var printText1 = true
    var text1 = "Thank you!"
    var tips = defaultTips
    var tipGuides: [Double] { return tips.map { $0.percent } }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        printLogo <- map["print_logo"]
        printStoreName <- map["print_store_name"]
        printAddress <- map["print_address"]
        printPhone <- map["print_phone"]
        printTableNo <- map["print_table_no"]
        printOrderNo <- map["print_order_no"]
        printNoOfGuest <- map["print_no_of_guest"]
        printDateTime <- map["print_date_time"]
        printTransactionNo <- map["print_transaction_no"]
        printServerName <- map["print_server_name"]
        printItemsName1 <- map["print_items_name_1"]
        printItemsName2 <- map["print_items_name_2"]
        printCustomerInfo <- map["print_customer_info"]
        printTipGuide <- map["print_tip"]
        printText1 <- map["print_text_1"]
        text1 <- map["text_1"]
        tips <- map["tips"]
    }
}

/// Contain all the settings for credit card receipt printing. This is common settings for all kind of kitchen printing including Send, Resend, Void.
class CCReceiptPrintingSettings: PrintingSettings {
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "ptl_cc_receipt" }
    
    var printLogo = true
    var printStoreName = true
    var printAddress = true
    var printPhone = true
    var printDateTime = true
    var printMerchantID = true
    var printTransactionNo = true
    var printCardType = true
    var printCardNo = true
    var printAuthCode = true
    var printTipGuide = true
    var printSignature = true
    var printOrderNo = true
    var printTableNo = true
    var printText1 = true
    var text1 = "I agree to pay the above total amount according to the card issuer agreement."
    var printText2 = true
    var text2: String = ""
    var tips = defaultTips
    var tipGuides: [Double] { return tips.map { $0.percent } }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        printLogo <- map["print_logo"]
        printStoreName <- map["print_store_name"]
        printAddress <- map["print_address"]
        printPhone <- map["print_phone"]
        printDateTime <- map["printDateTime"]
        printMerchantID <- map["print_merchant_id"]
        printTransactionNo <- map["print_transaction_no"]
        printCardType <- map["print_card_type"]
        printCardNo <- map["print_card_no"]
        printAuthCode <- map["print_auth_code"]
        printTipGuide <- map["print_tip"]
        printSignature <- map["print_signature"]
        printText1 <- map["print_text_1"]
        text1 <- map["text_1"]
        printText2 <- map["print_text_2"]
        text2 <- map["text_2"]
        tips <- map["tips"]
        printOrderNo <- map["print_order_no"]
        printTableNo <- map["print_table_no"]
    }
}

/// Contain all the settings for kitchen receipt printing. This is common settings for all kind of kitchen printing including Send, Resend, Void.
class LabelPrintingSettings: PrintingSettings {
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "ptl_label" }
    
    /// True if date should be printed.
    var printDate = true
    /// True if time should be printed.
    var printTime = true
    /// True if table number should be printed.
    var printTableNo = true
    /// True if order number should be printed.
    var printOrderNo = true
    /// True if modifiers should be printed.
    var printModifier = true
    /// True if note name should be printed.
    var printNote = true
    /// True if item name should be printed.
    var printItemsName1 = true
    /// True if item name 2 should be printed.
    var printItemsName2 = true
    /// True if item should be grouped by categories for printing.
    var printSeparateItem = true

    override func mapping(map: Map) {
        super.mapping(map: map)
        printDate <- map["print_date"]
        printTime <- map["print_time"]
        printTableNo <- map["print_table_no"]
        printOrderNo <- map["print_order_no"]
        printModifier <- map["print_modifier"]
        printNote <- map["print_note"]
        printItemsName1 <- map["print_items_name_1"]
        printItemsName2 <- map["print_items_name_2"]
        printSeparateItem <- map["print_separate_item"]
    }
}
