//
//  CCService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/7/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

/// Error relating to credit card service.
enum CCError: Error {
    case invalidDevice(detail: String)
    case invalidRequest(detail: String)
    case invalidReponse(detail: String)
    case transactionError(detail: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidDevice(let detail):
            return detail
        case .invalidRequest(let detail):
            return detail
        case .invalidReponse(let detail):
            return detail
        case .transactionError(let detail):
            return detail
        }
    }
}

protocol CCResult {
    var isApproved: Bool { get }
    var resultCode: String { get }
    var resultTxt: String { get }
    var message: String? { get }
    var extData: String? { get }
    var hostCode: String? { get }
    var authCode: String? { get }
}
protocol PaymentResult: CCResult {
    var displayCode: String { get }
    var displayMessage: String { get }
    
    var avsResponse: String? { get }
    var bogusAccountNum: String? { get }
    var cardType: String? { get }
    var cvResponse: String? { get }
    var hostResponse: String? { get }
    var approvedAmount: Double { get }
    var refNum: String? { get }
    var remainingBalance: Double { get }
    var extraBalance: Double { get }
    var requestedAmount: Double { get }
    var timestamp: String? { get }
    var rawResponse: String? { get }
}
protocol BatchResult: CCResult {
    var batchNum: String? { get }
    var hostTraceNum: String? { get }
    var mid: String? { get }
    var tid: String? { get }
    var timestamp: String? { get }
    var totalAmount: Double { get }
    var totalCount: Int { get }
    var hostResponse: String? { get }
}

/// During operationing, there are many phases including finding device and then sending request to device for payment
enum CCStatus {
    /// Finding device phase
    case findingDevice
    /// Request sent to device, awaiting reponse.
    case awaitingResponse
    /// Request complted with response
    case completed(result: CCResult)
    /// Request complted with response
    case completedWithError(error: Error)
}

/// Callback for updating status of the transactions.
typealias CCCallback = (CCStatus) -> Void
fileprivate let EmptyCCCallback: CCCallback = { _ in }

/// Represent a payment system.
protocol CCService {

    /// Request SALE using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - amount: the amount to perform.
    ///   - updateStatus: the callback to update status.
    /// - Returns: Promise of a `PaymentResult`.
    func sale(_ device: CCDevice, by employee: Employee, amount: Double, statusCallback updateStatus: @escaping  CCCallback) -> Promise<PaymentResult>
    
    /// Request REFUND using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - amount: the amount to perform.
    ///   - updateStatus: the callback to update status.
    /// - Returns: Promise of a `PaymentResult`.
    func refund(_ device: CCDevice, by employee: Employee, amount: Double, statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult>
    
    /// Request FORCE using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - amount: the amount to perform.
    ///   - updateStatus: the callback to update status.
    /// - Returns: Promise of a `PaymentResult`.
    func force(_ device: CCDevice, by employee: Employee, amount: Double, authCode: String, statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult>
    
    /// Request ADJUST using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - trans: the transaction to perform on.
    ///   - amount: the amount to perform.
    ///   - updateStatus: the callback to update status.
    /// - Returns: Promise of a `PaymentResult`.
    func adjust(_ device: CCDevice, by employee: Employee, trans transID: String, amount: Double, statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult>
    
    /// Request VOICE using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - trans: the transaction to perform on.
    ///   - updateStatus: the callback to update status.
    /// - Returns: Promise of a `PaymentResult`.
    func void(_ device: CCDevice, by employee: Employee, trans transID: String, statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult>
    
    /// Request CLOSEBATCH using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - updateStatus: the callback to update status.
    /// - Returns: Promise of a `BatchResult`.
    func close(batch device: CCDevice, statusCallback updateStatus: @escaping CCCallback) -> Promise<BatchResult>
}

/// PAX specific implementation of CCRequest
protocol PaxRequest {
    func set(link: PosLink) -> processType
    func get(response link: PosLink) -> CCResult
}
extension PaymentRequest: PaxRequest {
    func set(link: PosLink) -> processType {
        link.paymentRequest = self
        return PAYMENT
    }
    func get(response link: PosLink) -> CCResult {
        return PaxPaymentResult(link.paymentResponse)
    }
}
extension BatchRequest: PaxRequest {
    func set(link: PosLink) -> processType {
        link.batchRequest = self
        return BATCH
    }
    func get(response link: PosLink) -> CCResult {
        return PaxBatchResult(link.batchResponse)
    }
}

/// Credit card transaction result specific to PAX.
class PaxPaymentResult: PaymentResult {
    /// The pax response
    private let res: PaymentResponse
    
    init(_ res: PaymentResponse) {
        self.res = res
    }
    
    func toDouble(_ str: String?) -> Double {
        guard let str = str else { return 0.0 }
        return (Double(str) ?? 0.0) / 100.0
    }
    var isApproved: Bool { return resultCode == "000000" }
    var avsResponse: String? { return res.avsResponse }
    var bogusAccountNum: String? { return res.bogusAccountNum }
    var cardType: String? { return res.cardType }
    var cvResponse: String? { return res.cvResponse }
    var hostCode: String? { return res.hostCode }
    var hostResponse: String? { return res.hostResponse }
    var message: String? { return res.message }
    var approvedAmount: Double { return toDouble(res.approvedAmount) }
    var refNum: String? { return res.refNum }
    var remainingBalance: Double { return toDouble(res.remainingBalance) }
    var extraBalance: Double { return toDouble(res.extraBalance) }
    var requestedAmount: Double { return toDouble(res.requestedAmount) }
    var resultCode: String { return res.resultCode }
    var resultTxt: String { return res.resultTxt }
    var timestamp: String? { return res.timestamp }
    var extData: String? { return res.extData }
    var rawResponse: String? { return res.rawResponse }
    var authCode: String? { return res.authCode }
    
    var displayCode: String { return resultCode.isEmpty ? "ERR" : resultCode }
    var displayMessage: String {
        guard let message = message, message.isNotEmpty else { return resultTxt }
        return message
    }
}

/// Credit card close batch result specific to PAX.
class PaxBatchResult: BatchResult {
    private let res: BatchResponse
    init(_ res: BatchResponse) {
        self.res = res
    }
    
    func toDouble(_ str: String?) -> Double {
        guard let str = str else { return 0.0 }
        return (Double(str) ?? 0.0) / 100.0
    }
    
    func toInt(_ str: String?) -> Int {
        guard let str = str else { return 0 }
        return Int(str) ?? 0
    }
    var isApproved: Bool { return resultCode == "000000" }
    var hostCode: String? { return res.hostCode }
    var authCode: String? { return res.authCode }
    var batchNum: String? { return res.batchNum }
    var hostTraceNum: String? { return res.hostTraceNum }
    var mid: String? { return res.mid }
    var tid: String? { return res.tid }
    var timestamp: String? { return res.timestamp }
    var totalAmount: Double { return toDouble(res.creditAmount) }
    var totalCount: Int { return toInt(res.creditCount) }
    var hostResponse: String? { return res.hostResponse }
    var message: String? { return res.message }
    var extData: String? { return res.extData }
    var resultCode: String { return res.resultCode }
    var resultTxt: String { return res.resultTxt }
}

/// For closing batch of non-card transactions.
class NonCardBatchResult: BatchResult {
    var isApproved: Bool { return true }
    var hostCode: String? { return nil }
    var authCode: String? { return nil }
    var batchNum: String? { return nil }
    var hostTraceNum: String? { return nil }
    var mid: String? { return nil }
    var tid: String? { return nil }
    var timestamp: String? { return nil }
    var totalAmount: Double = 0.0
    var totalCount: Int = 0
    var hostResponse: String? { return nil }
    var message: String? { return nil }
    var extData: String? { return nil }
    var resultCode: String { return "" }
    var resultTxt: String { return "" }
    init(transactions: [Transaction]) {
        self.totalCount = transactions.count
        self.totalAmount = transactions.reduce(0.0, { (r, t) in r + t.approvedAmountByStatus })
    }
}

/// PAX payment system.
class PaxCCService: CCService, ServiceConsumer {
    
    private lazy var scanner = MacAddressScanner()
    private let queue = DispatchQueue(label: "PaxCCService", qos: .background)
    
    /// Find a `CCDevice` using its MAC address and update its IP if need to
    ///
    /// - Parameters:
    ///   - device: The `CCDevice` to perform the payment with.
    ///   - updateStatus: Callback to update the status of payment.
    /// - Returns: `Promise` for a `CCDevice` with latest IP address.
    private func findAndUpdate(_ device: CCDevice, _ updateStatus: CCCallback, _ existingError: Error?) -> Promise<CCDevice> {
        return Promise { (fullfill, reject) in
            // Finding device first
            if existingError == nil {
                updateStatus(.findingDevice)
            }
            let _reject = { (error: Error?) in
                if let existingError = existingError {
                    reject(existingError)
                } else if let error = error {
                    reject(error)
                } else {
                    reject(CCError.invalidDevice(detail: "Unknown error"))
                }
            }
            // Scan the network
            scanner
                .scan(for: device.macAddress) { (ip, error) in
                    if let _ = error {
                        return _reject(CCError.invalidDevice(detail: "Could not find credit card device"))
                    }
                    guard let ip = ip, ip.isNotEmpty else {
                        return _reject(CCError.invalidDevice(detail: "Could not find credit card device"))
                    }
                    // If device's IP has changed, update it. This update is minor, thus error will be logged and ignored.
                    if device.ipAddress != ip {
                        do {
                            device.ipAddress = ip
                            try self.database.save(device)
                        }
                        catch {
                            w("Could not update device (\(device)) IP address. \n\(error.localizedDescription)")
                        }
                        // Call completion to continue
                        fullfill(device)
                    } else {
                        _reject(nil)
                    }
            }
        }
    }
    
    /// Perform the request with given URL
    ///
    /// - Parameters:
    ///   - url: base URL
    ///   - request: the request builder
    ///   - updateStatus: the status callback
    /// - Returns: `Promise` of `PaymentResult`.
    private func send<T: CCResult>(_ request: @escaping () throws -> PaxRequest, to device: CCDevice, callback updateStatus: @escaping CCCallback) -> Promise<T> {
        return Promise { fulfill, reject in
            queue.async {
                do {
                    let sud = UserDefaults.standard
                    if device.ipAddress != sud.string(forKey: "destIP") {
                        sud.setValue(device.ipAddress, forKey: "destIP")
                        sud.setValue("10009", forKey: "destPort")
                        sud.setValue("60000", forKey: "timeout")
                        sud.setValue("TCP", forKey: "commType")
                        sud.synchronize()
                    }
                    
                    let req = try request()
                    // This will load CommSetting from UserDefaults
                    let link = PosLink()
                    let type = req.set(link: link)
                    guard let result = link.processTrans(type) else {
                        return reject(CCError.invalidReponse(detail: "Empty response"))
                    }
                    switch result.code {
                    case OK:
                        fulfill(req.get(response: link) as! T)
                    case TIMEOUT:
                        reject(CCError.transactionError(detail: "Timeout processing transaction."))
                    case ERROR:
                        reject(CCError.transactionError(detail: "Error processing transaction: \(result.msg!)"))
                    default:
                        reject(CCError.transactionError(detail: "Unknown result code: \(result.code.rawValue)"))
                    }
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    /// First find the device, then perform the transaction request
    ///
    /// - Parameters:
    ///   - device: The `CCDevice` to perform the payment with.
    ///   - updateStatus: Callback to update the status of payment.
    ///   - request: The request to send to the physical device.
    /// - Returns: The `Promise` for a good `PaymentResult`.
    private func findAndRequest<T: CCResult>(_ device: CCDevice, _ updateStatus: @escaping CCCallback, request: @escaping () throws -> PaxRequest) -> Promise<T> {
        return Promise<T> { fullfill, reject in
            // Guard device
            guard device.enabled else {
                return reject(CCError.invalidDevice(detail: "Device is disabled"))
            }
            guard device.ccDeviceType == .ethernet else {
                return reject(CCError.invalidDevice(detail: "Device type is not supported"))
            }
            guard !device.port.isEmpty else {
                return reject(CCError.invalidDevice(detail: "Device's port is invalid"))
            }
            guard !device.macAddress.isEmpty else {
                return reject(CCError.invalidDevice(detail: "Device does not have MAC address"))
            }
            
            // Fullfill with status update
            let _fullfill = { (transactionResult: T) -> Void in
                // Inform about the status
                updateStatus(.completed(result: transactionResult))
                // End this request with success result
                fullfill(transactionResult)
            }
            // Reject with status update
            let _reject = { (error: Error) -> Void in
                updateStatus(.completedWithError(error: error))
                reject(error)
            }
            // Find then request
            let _findAndRequest = { (error: Error?) -> Void in
                self.findAndUpdate(device, updateStatus, error)
                    .then { _ -> Promise<T> in
                        self.send(request, to: device, callback: updateStatus)
                    }.then { transactionResult -> Void in
                        _fullfill(transactionResult)
                    }.catch { error in
                        _reject(error)
                }
            }
            
            // Check if the IP is duplicated
            if device.ipAddress.isEmpty {
                _findAndRequest(nil)
            } else {
                send(request, to: device, callback: updateStatus)
                    .then { transactionResult -> Void in
                        _fullfill(transactionResult)
                    }.catch { error in
                        // It's possible that the IP address has changed to a different value comparing tto the stored one, we need to give it another shot.
                        _reject(error)
                        //_findAndRequest(error)
                }
            }
        }
    }
    
    func sale(_ device: CCDevice, by employee: Employee, amount: Double, statusCallback updateStatus: @escaping  CCCallback) -> Promise<PaymentResult> {
        return Promise { fulfill, reject in
            findAndRequest(device, updateStatus) { 
                guard amount > 0 else {
                    throw CCError.invalidRequest(detail: "Amount must greater than 0 for credit/sale request")
                }
                guard employee.id.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "User ID is required for credit/sale request")
                }
                // 1. First create a request with tender type and trans type
                let request = PaymentRequest()
                request.tenderType = PaymentRequest.parseTenderType("CREDIT")
                request.transType = PaymentRequest.parseTransType("SALE")
                // 2. Next Set the PayLink Properties, the only required field is Amount
                request.amount =  String(format: "%.0f", (amount * 100))
                request.clerkID = employee.id.suffix(3)
                request.ecrRefNum = "1"
                // 3. Other optional data
                return request
                }
                .then { (r: PaxPaymentResult) -> Void in fulfill(r) }
                .catch { e in reject(e) }
        }
    }
    
    func refund(_ device: CCDevice, by employee: Employee, amount: Double, statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult> {
        return Promise { fulfill, reject in
            findAndRequest(device, updateStatus) {
                guard amount > 0 else {
                    throw CCError.invalidRequest(detail: "Amount must greater than 0 for refund request")
                }
                guard employee.id.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "User ID is required for refund request")
                }
                // 1. First create a request with tender type and trans type
                let request = PaymentRequest()
                request.tenderType = PaymentRequest.parseTenderType("CREDIT")
                request.transType = PaymentRequest.parseTransType("RETURN")
                // 2. Next Set the PayLink Properties, the only required field is Amount
                request.amount =  String(format: "%.0f", (amount * 100))
                request.clerkID = employee.id.suffix(3)
                request.ecrRefNum = "1"
                // 3. Other optional data
                return request
                }
                .then { (r: PaxPaymentResult) -> Void in fulfill(r) }
                .catch { e in reject(e) }
        }
    }
    
    func force(_ device: CCDevice, by employee: Employee, amount: Double, authCode: String, statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult> {
        return Promise { fulfill, reject in
            findAndRequest(device, updateStatus) {
                guard amount > 0 else {
                    throw CCError.invalidRequest(detail: "Amount must greater than 0 for force request")
                }
                guard employee.id.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "User ID is required for force request")
                }
                guard authCode.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "Authorization Code is required for force request")
                }
                // 1. First create a request with tender type and trans type
                let request = PaymentRequest()
                request.tenderType = PaymentRequest.parseTenderType("CREDIT")
                request.transType = PaymentRequest.parseTransType("FORCEAUTH")
                // 2. Next Set the PayLink Properties, the only required field is Amount
                request.amount =  String(format: "%.0f", (amount * 100))
                request.clerkID = employee.id.suffix(3)
                request.authCode = authCode
                request.ecrRefNum = "1"
                // 3. Other optional data
                return request
                }
                .then { (r: PaxPaymentResult) -> Void in fulfill(r) }
                .catch { e in reject(e) }
        }
    }
    
    func adjust(_ device: CCDevice, by employee: Employee, trans transID: String, amount: Double,statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult> {
        return Promise { fulfill, reject in
            findAndRequest(device, updateStatus) {
                guard amount > 0 else {
                    throw CCError.invalidRequest(detail: "Amount must greater than 0 for adjustment request")
                }
                guard employee.id.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "User ID is required for adjustment request")
                }
                guard transID.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "Trans ID is required for adjustment request")
                }
                // 1. First create a request with tender type and trans type
                let request = PaymentRequest()
                request.tenderType = PaymentRequest.parseTenderType("CREDIT")
                request.transType = PaymentRequest.parseTransType("ADJUST")
                // 2. Next Set the PayLink Properties, the only required field is Amount
                request.amount =  String(format: "%.0f", (amount * 100))
                request.clerkID = employee.id.suffix(3)
                request.origRefNum = transID
                request.ecrRefNum = "1"
                // 3. Other optional data
                return request
                }
                .then { (r: PaxPaymentResult) -> Void in fulfill(r) }
                .catch { e in reject(e) }
        }
    }
    
    func void(_ device: CCDevice, by employee: Employee, trans transID: String, statusCallback updateStatus: @escaping CCCallback) -> Promise<PaymentResult> {
        return Promise { fulfill, reject in
            return findAndRequest(device, updateStatus) {
                guard employee.id.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "User ID is required for void request")
                }
                guard transID.isNotEmpty else {
                    throw CCError.invalidRequest(detail: "Trans ID is required for void request")
                }
                // 1. First create a request with tender type and trans type
                let request = PaymentRequest()
                request.tenderType = PaymentRequest.parseTenderType("CREDIT")
                request.transType = PaymentRequest.parseTransType("VOID")
                // 2. Next Set the PayLink Properties, the only required field is Amount
                request.clerkID = employee.id.suffix(3)
                request.origRefNum = transID
                request.ecrRefNum = "1"
                // 3. Other optional data
                return request
                }
                .then { (r: PaxPaymentResult) -> Void in fulfill(r) }
                .catch { e in reject(e) }
        }
    }
    
    func close(batch device: CCDevice, statusCallback updateStatus: @escaping CCCallback) -> Promise<BatchResult> {
        return Promise { fulfill, reject in
            return findAndRequest(device, updateStatus) {
                // 1. First create a request with tender type and trans type
                let request = BatchRequest()
                request.transType = BatchRequest.parseTransType("BATCHCLOSE")
                request.edcType = BatchRequest.parseEDCType("CREDIT")
                // 2. Next Set the PayLink Properties, the only required field is Amount
                //        request.clerkID = userID
                // 3. Other optional data
                return request
                }
                .then { (r: PaxBatchResult) -> Void in fulfill(r) }
                .catch { e in reject(e) }
        }
    }
}


