//
//  Transaction.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Transaction type.
///
/// - cash: Created by paying bill using Cash.
/// - custom: Created by paying bill using custom payment type.
/// - creditSale: Created by paying bill using Credit Card.
/// - creditVoid: Created by voiding any other transaction type.
/// - creditRefund: Created by refunding using Credit Card.
/// - creditForce: Created by forcing using Credit Card.
/// - batchclose: Created by closing batch of transactions.
enum TransactionType: String {
    case cash = "cash"
    case custom = "custom"
    case creditSale = "credit_sale"
    case creditVoid = "credit_void"
    case creditRefund = "credit_refund"
    case creditForce = "credit_force"
    case batchclose = "batch_close"
    
    /// `true` if the transaction has a check for printing
    var hasCheck: Bool {
        switch self {
        case .cash: return true
        case .custom: return true
        case .creditSale: return true
        case .creditVoid: return false
        case .creditRefund: return false
        case .creditForce: return false
        case .batchclose: return false
        }
    }
    
    /// `true` if the transaction can has tip.
    var hasTip: Bool {
        switch self {
        case .cash: return true
        case .custom: return true
        case .creditSale: return true
        case .creditVoid: return false
        case .creditRefund: return false
        case .creditForce: return false
        case .batchclose: return false
        }
    }
}

/// Status of a Transaction.
///
/// - new: Just created.
/// - settled: Already settled.
/// - voided: Already voided but not settled
/// - voidedSettled: Already settled.
enum TransactionStatus: String {
    case new = "new"
    case settled = "settled"
    case voided = "voided"
    case voidedSettled = "voided-settled"
    
    var isVoided: Bool {
        switch self {
        case .new: return false
        case .settled: return false
        case .voided: return true
        case .voidedSettled: return true
        }
    }
    
    var isSettled: Bool {
        switch self {
        case .new: return false
        case .settled: return true
        case .voided: return false
        case .voidedSettled: return true
        }
    }
}

/// Represent a `Transaction` in the system, `Transaction` got created during payment of `Bill`. `Transaction` could be of type credit card, cash or custom type defined by the web admin.
class Transaction: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "transaction" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "trs" }
    
    // MARK: - Type and Status
    /// Transaction type
    var transType: TransactionType = .cash
    /// Transaction status
    var transStatus: TransactionStatus = .new
    // MARK: - Area/Table
    var area = ""
    var areaName = ""
    var table = ""
    var tableName = ""
    // MARK: - Payment device
    /// Payment device ID
    var paymentDevice = ""
    /// Payment device Name
    var paymentDeviceName = ""
    // MARK: - Custom Payment Type
    /// Custom transaction type (used when the transType is .custom one)
    var customTransType = ""
    /// Custom transaction type name (used when the transType is .custom one)
    var customTransTypeName = ""
    // MARK: - Sub payment type
    /// Sub payment type ID
    var subPaymentType = ""
    /// Sub payment type Name
    var subPaymentTypeName = ""
    /// The Order this trans originated for, this only make sense for CREDIT_SALE.
    var order = ""
    /// The Bill this trans originated for, this only make sense for CREDIT_SALE.
    var bill = ""
    /// Employee ID who created this tran.
    var createdBy = ""
    // MARK: - Shift
    /// The Shift ID in which this trans is created.
    var shift = ""
    /// The Shift index in which this trans is created.
    var shiftIndex: UInt = 0
    /// The transaction number.
    var transNum: UInt64 = 0
    /// The order number.
    var orderNum: UInt = 0
    // MARK: - Amounts
    /// Return the total Credit Amount.
    var creditAmount: Double = 0
    // MARK: - Voiding
    /// Hold the employee id who void this transaction.
    var voidedBy = ""
    /// The timestamp when voiding happens.
    var voidedAt = ""
    /// Hold the reason of voiding.
    var voidedReason = ""
    // MARK: - Tip Adjustment
    /// Tip Amount, this value can be set by tip adjusting.
    var tipAmount: Double = 0
    /// Employee ID who adjust the Tip of this trans.
    var adjustedBy = ""
    /// The timestamp when tip adjustment happens.
    var adjustedAt = ""
    // MARK: - PAX Transaction
    var avsResponse = ""
    var cardNum = ""
    var cardType = ""
    var cvResponse = ""
    var hostCode = ""
    var hostResponse = ""
    var message = ""
    /// The amount approved by PAX, this should be the same as RequestedAmount though there is case where the approved amount is less than the RequestedAmount.
    var approvedAmount: Double = 0
    var refNum  = ""
    var remainingBalance: Double = 0
    var extraBalance: Double = 0
    /// The amount request for payment, this make sense for CREDIT_SALE, CREDIT_FORCE, CREDIT_REFUND.
    var requestedAmount: Double = 0
    var resultCode = ""
    var resultTxt = ""
    var timestamp = ""
    var extData = ""
    var rawResponse = ""
    var authCode = ""
    // MARK: - PAX CloseBatch
    var batchNum = ""
    var totalCount: Int = 0
    var totalAmount: Double = 0
    /// Hold the employee id who settled this normal trans or created CLOSEBATCH trans.
    var settledBy = ""
    /// Hold the time of settled for normal transactions and created time of CLOSEBATCH transaction.
    var settledAt = "'"
    /// Hold the ID of CLOSEBATCH transaction that settle/close this transaction.
    var settlingTrans = ""
    /// Keep the list of transactions that are settled/closed by this CLOSEBATCH.
    var settledTrans: [String] = []
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        transType <- (map["trans_type"], EnumTransform<TransactionType>())
        transStatus <- (map["status"], EnumTransform<TransactionStatus>())
        area <- map["area"]
        areaName <- map["area_name"]
        table <- map["table"]
        tableName <- map["table_name"]
        paymentDevice <- map["payment_device"]
        paymentDeviceName <- map["payment_device_name"]
        customTransType <- map["custom_trans_type"]
        customTransTypeName <- map["custom_trans_type_name"]
        subPaymentType <- map["sub_payment_type"]
        subPaymentTypeName <- map["sub_payment_type_name"]
        order <- map["order"]
        bill <- map["bill"]
        createdBy <- map["created_by"]
        shift <- map["shift"]
        shiftIndex <- map["shift_index"]
        transNum <- map["trans_num"]
        orderNum <- map["order_no"]
        creditAmount <- map["credit_amount"]
        voidedBy <- map["voided_by"]
        voidedAt <- map["voided_at"]
        voidedReason <- map["void_reason"]
        tipAmount <- map["tip_amount"]
        adjustedBy <- map["adjusted_by"]
        adjustedAt <- map["adjusted_at"]
        avsResponse <- map["avs_response"]
        cardNum <- map["bogus_account_num"]
        cardType <- map["card_type"]
        cvResponse <- map["cv_response"]
        hostCode <- map["host_code"]
        hostResponse <- map["host_response"]
        message <- map["message"]
        approvedAmount <- map["approved_amount"]
        refNum <- map["ref_num"]
        remainingBalance <- map["remaining_balance"]
        extraBalance <- map["extra_balance"]
        requestedAmount <- map["requested_amount"]
        resultCode <- map["result_code"]
        resultTxt <- map["result_txt"]
        timestamp <- map["timestamp"]
        extData <- map["ext_data"]
        rawResponse <- map["raw_response"]
        authCode <- map["auth_code"]
        batchNum <- map["batch_num"]
        totalCount <- map["total_count"]
        totalAmount <- map["total_amount"]
        settledBy <- map["settled_by"]
        settledAt <- map["settled_at"]
        settlingTrans <- map["settling_trans"]
        settledTrans <- map["settled_transactions"]
    }
}

extension Transaction {
    /// Create new generic transaction.
    ///
    /// - Parameters:
    ///   - database: The `CBLDatabase` to create for.
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this.
    ///   - subPaymentType: The `PaymentType` selected during payment.
    /// - Returns: The `Transaction`.
    convenience init(inStore store: Store, forShift shift: Shift, byServer employee: Employee) {
        self.init()
        type = Transaction.documentType
        merchantID = store.merchantID
        storeID = store.id
        channels = ["ord_\(store.id)"]
        transStatus = .new
        createdBy = employee.id
        self.shift = shift.id
        shiftIndex = shift.index
        transNum = shift.transNum
    }
}

extension Transaction {
    var hasPaymentDevice: Bool { return paymentDevice.isNotEmpty }
    /// True if both order and bill are not empty.
    var hasBill: Bool { return order.isNotEmpty && bill.isNotEmpty }
    /// Return the amount with respect to transaction type.
    /// If it is a REFUND, return negative number, otherwise positive number.
    var approvedAmountByStatus: Double { return transType == .creditRefund ? -approvedAmount : approvedAmount }    
    /// Return the amount with respect to transaction type.
    /// If it is a REFUND, return negative number, otherwise positive number.
    var calculatedAmountByStatus: Double {
        if transType == .creditRefund { return -approvedAmount }
        if isVoided { return 0.0 }
        return approvedAmount
    }
    /// Return the Sum of Approved and Tip Amount.
    /// This is a bit implicit because we assume REFUND has no TipAmount.
    /// Thus adding TipAmount to REFUND amount with status means nothing got added.
    var totalWithTipAmount: Double { return approvedAmountByStatus + tipAmount }
    /// True if the transaction is VOIDED (settled or not).
    var isVoided: Bool { return transStatus == .voided || transStatus == .voidedSettled }
    /// Only credit sale transaction can be voided.
    var canVoid: Bool { return transStatus == .new }
    /// Only credit sale transaction can be adjusted.
    var canAdjust: Bool { return transStatus == .new && transType.hasTip }

    override var debugDescription: String {
        return "\(super.debugDescription) #\(transNum)"
    }
}
