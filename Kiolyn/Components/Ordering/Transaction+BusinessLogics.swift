//
//  Transaction+BusinessLogics.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - For displaying on screen
extension Transaction {
    
    /// For displaying on bill and report.
    var displayCardType: String {
        guard self.cardType.isNotEmpty else { return "" }
        let cardType = self.cardType.uppercased()
        if cardType == "MASTERCARD" { return "MASTER" }
        else { return cardType }
    }
    
    /// For displaying on bill and report.
    var displayTransType: String {
        var name = ""
        switch self.transType {
        case .cash: name = "CASH"
        case .custom: name = customTransTypeName.uppercased()
        case .creditSale: name = "CREDIT"
        case .creditVoid: name = "VOID"
        case .creditRefund: name = "REFUND"
        case .creditForce: name = "FORCE"
        case .batchclose: name = "CLOSE"
        }
        if self.subPaymentType.isNotEmpty {
            name += " - \(self.subPaymentTypeName)"
        }
        return name.uppercased()
    }
    
    /// For displaying in Bill payment info.
    var paidInfo: String {
        if self.transType == .creditSale {
            return "\(self.displayCardType) **** \(self.cardNum)".uppercased()
        }
        
        return self.displayTransType
    }
}

// MARK: - Creation/Factory
extension Transaction {
    
    /// Copy values from `PaymentResult`, to be called by credit card related transaction.
    ///
    /// - Parameter res: The `PaymentResult` to copy from.
    func set(result: PaymentResult) {
        avsResponse = result.avsResponse ?? ""
        cardNum = result.bogusAccountNum ?? ""
        cardType = result.cardType ?? ""
        cvResponse = result.cvResponse ?? ""
        hostCode = result.hostCode ?? ""
        hostResponse = result.hostResponse ?? ""
        message = result.message ?? ""
        approvedAmount = result.approvedAmount
        refNum = result.refNum ?? ""
        remainingBalance = result.remainingBalance
        extraBalance = result.extraBalance
        requestedAmount = result.requestedAmount
        resultCode = result.resultCode
        resultTxt = result.resultTxt
        timestamp = result.timestamp ?? ""
        extData = result.extData ?? ""
        rawResponse = result.rawResponse ?? ""
        authCode = result.authCode ?? ""
    }
    
    /// Copy values from `BatchResult`, to be called by credit card related transaction.
    ///
    /// - Parameter res: The `BatchResult` to copy from.
    func set(result: BatchResult) {
        hostCode = result.hostCode ?? ""
        authCode = result.authCode ?? ""
        batchNum = result.batchNum ?? ""
        totalAmount = result.totalAmount
        totalCount = result.totalCount
        hostResponse = result.hostResponse ?? ""
        message = result.message ?? ""
        extData = result.extData ?? ""
        resultCode = result.resultCode
        resultTxt = result.resultTxt
    }
    
    /// Create a CREDITCARD sale transaction.
    ///
    /// - Parameters:
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this.
    ///   - ccDevice: The `CCDevice` which generate this transaction.
    ///   - order: The `Order` to pay for.
    ///   - bill: The `Bill` to pay for.
    ///   - result: The `PaymentResult` from paying by card.
    ///   - subPaymentType: The `PaymentType` selected during payment.
    /// - Returns: The `Transaction`.
    convenience init(forCard store: Store, forShift shift: Shift, byEmployee employee: Employee, ccDevice: CCDevice, order: Order, bill: Bill, result: PaymentResult, subPaymentType: PaymentType? = nil) {
        self.init(inStore: store, forShift: shift, byServer: employee)
        transType = .creditSale
        self.order = order.id
        orderNum = order.orderNo
        table = order.table
        tableName = order.tableName
        area = order.area
        areaName = order.areaName
        self.bill = bill.id
        self.subPaymentType = subPaymentType?.id ?? ""
        subPaymentTypeName = subPaymentType?.name ?? ""
        paymentDevice = ccDevice.id
        paymentDeviceName = ccDevice.name
        set(result: result)
    }
    
    /// Create a CASH sale transaction.
    ///
    /// - Parameters:
    ///   - database: The `CBLDatabase` to create for.
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this.
    ///   - order: The `Order` to pay for.
    ///   - bill: The `Bill` to pay for.
    ///   - amount: The amount to pay.
    ///   - subPaymentType: The `PaymentType` selected during payment.
    /// - Returns: The `Transaction`.
    convenience init(forCash store: Store, forShift shift: Shift, byEmployee employee: Employee, order: Order, bill: Bill, amount: Double, subPaymentType: PaymentType? = nil) {
        self.init(inStore: store, forShift: shift, byServer: employee)
        transType = .cash
        self.order = order.id
        orderNum = order.orderNo
        self.table = order.table
        tableName = order.tableName
        area = order.area
        areaName = order.areaName
        self.bill = bill.id
        self.subPaymentType = subPaymentType?.id ?? ""
        subPaymentTypeName = subPaymentType?.name ?? ""
        requestedAmount = amount
        approvedAmount = amount
        self.tipAmount = bill.tip
    }
    
    /// Create a CUSTOM sale transaction.
    ///
    /// - Parameters:
    ///   - database: The `CBLDatabase` to create for.
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this.
    ///   - order: The `Order` to pay for.
    ///   - bill: The `Bill` to pay for.
    ///   - amount: The amount to pay.
    ///   - paymentType: The custom `PaymentType` selected during payment.
    ///   - subPaymentType: The `PaymentType` selected during payment.
    /// - Returns: The `Transaction`.
    convenience init(forCustom store: Store, forShift shift: Shift, byEmployee employee: Employee, order: Order, bill: Bill, amount: Double, paymentType: PaymentType, subPaymentType: PaymentType? = nil) {
        self.init(inStore: store, forShift: shift, byServer: employee)
        transType = .custom
        self.order = order.id
        orderNum = order.orderNo
        table = order.table
        tableName = order.tableName
        area = order.area
        areaName = order.areaName
        self.bill = bill.id
        self.subPaymentType = subPaymentType?.id ?? ""
        subPaymentTypeName = subPaymentType?.name ?? ""
        customTransType = paymentType.id
        customTransTypeName = paymentType.name
        requestedAmount = amount
        approvedAmount = amount
        self.tipAmount = bill.tip
    }
    
    /// Create a CREDITCARD refund transaction.
    ///
    /// - Parameters:
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this.
    ///   - ccDevice: The `CCDevice` which generate this transaction.
    ///   - result: The `PaymentResult` from paying by card.
    /// - Returns: The `Transaction`.
    convenience init(forRefund store: Store, forShift shift: Shift, byEmployee employee: Employee, ccDevice: CCDevice, result: PaymentResult) {
        self.init(inStore: store, forShift: shift, byServer: employee)
        transType = .creditRefund
        paymentDevice = ccDevice.id
        paymentDeviceName = ccDevice.name
        set(result: result)
    }
    
    /// Create a CREDITCARD force transaction.
    ///
    /// - Parameters:
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this.
    ///   - ccDevice: The `CCDevice` which generate this transaction.
    ///   - result: The `PaymentResult` from paying by card.
    /// - Returns: The `Transaction`.
    convenience init(forForce store: Store, forShift shift: Shift, byEmployee employee: Employee, ccDevice: CCDevice, result: PaymentResult) {
        self.init(inStore: store, forShift: shift, byServer: employee)
        transType = .creditForce
        paymentDevice = ccDevice.id
        paymentDeviceName = ccDevice.name
        set(result: result)
    }
    
    /// Create a close batch transaction to store information about closing batch of a shift that relates to a single CCDevice with its close batch result.
    ///
    /// - Parameters:
    ///   - store: The `Store` to create for.
    ///   - shift: The `Shift` to create in.
    ///   - employee: The `Employee` who creates this.
    ///   - ccDevice: The `CCDevice` which generate this transaction.
    ///   - result: The `PaymentResult` from paying by card.
    ///   - settledTrans: The `Transaction`s got settled by this close batch.
    /// - Returns: The `Transaction`.
    convenience init(forCloseBatch store: Store, forShift shift: Shift, byEmployee employee: Employee, ccDevice: CCDevice? = nil, result: BatchResult? = nil, settledTrans: [Transaction]) {
        self.init(inStore: store, forShift: shift, byServer: employee)
        transStatus = .settled // Settled by itself
        transType = .batchclose
        paymentDevice = ccDevice?.id ?? ""
        paymentDeviceName = ccDevice?.name ?? ""
        settledBy = employee.id
        settledAt = BaseModel.timestamp
        self.settledTrans = settledTrans.map{ $0.id }
        if let result = result {
            set(result: result)
        }
    }
}

// MARK: - Modification.
extension Transaction {
    /// Adjust tip for this transaction.
    ///
    /// - Parameters:
    ///   - amount: the tip amount to adjust.
    ///   - employee: the employee who performs the adjustment.
    func adjust(tip amount: Double, by employee: Employee) -> Transaction {
        tipAmount = amount
        adjustedBy = employee.id
        adjustedAt = BaseModel.timestamp
        return self
    }
    
    /// Settle this transaction.
    ///
    /// - Parameters:
    ///   - trans: the settling transaction.
    ///   - employee: the employee who performs the settling.
    func settle(by trans: Transaction, by employee: Employee) -> Transaction {
        transStatus = transStatus == .voided ? .voidedSettled : .settled
        settledBy = employee.id
        settledAt = BaseModel.timestamp
        settlingTrans = trans.id
        return self
    }
    
    /// Void this transaction
    ///
    /// - Parameters:
    ///   - reason: the reason for voiding
    ///   - employee: the employee who performs the voiding.
    /// - Returns: the `Transaction` in voided status, or nil if the voiding condition does not match.
    func void(with reason: String, by employee: Employee) -> Transaction? {
        guard self.canVoid, reason.isNotEmpty else { return nil }
        transStatus = .voided
        voidedReason = reason
        voidedBy = employee.id
        voidedAt = BaseModel.timestamp
        return self
    }
    
    /// Change the sub payment type.
    ///
    /// - Parameter subType: the subtype to change, nil ~ clear sub payment type.
    func set(subPaymentType subType: PaymentType?) -> Transaction {
        if let st = subType {
            subPaymentType = st.id
            subPaymentTypeName = st.name
        } else {
            subPaymentType = ""
            subPaymentTypeName = ""
        }
        return self
    }
}
