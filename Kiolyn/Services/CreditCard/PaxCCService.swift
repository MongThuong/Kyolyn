//
//  PaxCCService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import MMLanScan
import SwiftyUserDefaults

class PaxCCService: CCService {
    
    private lazy var scanner = MacAddressScanner()
    private let queue = DispatchQueue(label: "PaxCCService", qos: .background)
    
    func sale(amount: Double, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus> {
        return findAndRequest(device, message: "Please swipe or input card ...") {
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
    }
    
    func refund(amount: Double, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus> {
        return findAndRequest(device, message: "Please swipe or input card ...") {
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
    }
    
    func force(amount: Double, using device: CCDevice, byEmployee employee: Employee, with authCode: String) -> Observable<CCStatus> {
        return findAndRequest(device, message: "Please swipe or input card ...") {
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
    }
    
    func adjust(trans transID: String, newTipAmount amount: Double, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus> {
        return findAndRequest(device) {
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
    }
    
    func void(trans transID: String, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus> {
        return findAndRequest(device) {
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
    }
    
    func close(batch device: CCDevice) -> Observable<CCStatus> {
        return findAndRequest(device) {
            // 1. First create a request with tender type and trans type
            let request = BatchRequest()
            request.transType = BatchRequest.parseTransType("BATCHCLOSE")
            request.edcType = BatchRequest.parseEDCType("CREDIT")
            // 2. Next Set the PayLink Properties, the only required field is Amount
            //        request.clerkID = userID
            // 3. Other optional data
            return request
        }
    }
    
    /// First find the device, then perform the transaction request
    ///
    /// - Parameters:
    ///   - device: The `CCDevice` to perform the payment with.
    ///   - updateStatus: Callback to update the status of payment.
    ///   - request: The request to send to the physical device.
    /// - Returns: The `Promise` for a good `PaymentResult`.
    private func findAndRequest(_ device: CCDevice, message: String = "Contacting payment device ...", request: @escaping () throws -> PaxRequest) -> Observable<CCStatus> {
        guard device.enabled else {
            return Observable.error(CCError.invalidDevice(detail: "Device is disabled"))
        }
        guard device.ccDeviceType == .ethernet else {
            return Observable.error(CCError.invalidDevice(detail: "Device type is not supported"))
        }
        guard !device.port.isEmpty else {
            return Observable.error(CCError.invalidDevice(detail: "Device's port is invalid"))
        }
        guard !device.macAddress.isEmpty else {
            return Observable.error(CCError.invalidDevice(detail: "Device does not have MAC address"))
        }
        return Observable.create { observer -> Disposable in
            // Find then request
            let _findAndSend: () -> Disposable = {
                observer.onNext(CCStatus.progress(detail: "Scanning for device ..."))
                return self.scan(for: device)
                    .flatMap { newIP -> Single<CCDevice?> in
                        guard newIP != device.ipAddress else {
                            observer.onError(CCError.deviceNotFound)
                            return Single.just(nil)
                        }
                        device.ipAddress = newIP
                        return SP.dataService.save(device)
                    }
                    .flatMap { device -> Single<CCResult?> in
                        guard let device = device else {
                            return Single.just(nil)
                        }
                        observer.onNext(CCStatus.progress(detail: message))
                        return self.send(request, to: device).map { res -> CCResult? in res }
                    }
                    .subscribe(onSuccess: { result in
                        guard let result = result else {
                            observer.onError(CCError.unknown)
                            return
                        }
                        observer.onNext(.completed(result: result))
                        observer.onCompleted()
                    }, onError: { error in observer.onError(error) })                
            }

            if device.ipAddress.isEmpty {
                return _findAndSend()
            } else {
                observer.onNext(CCStatus.progress(detail: message))
                return self.send(request, to: device)
                    .subscribe(onSuccess: { res in
                        observer.onNext(.completed(result: res))
                        observer.onCompleted()
                    }, onError: { error in
                        _ = _findAndSend()
                    })
            }
//            return Disposables.create()
        }
    }
    
    /// Perform the request with given URL
    ///
    /// - Parameters:
    ///   - url: base URL
    ///   - request: the request builder
    ///   - updateStatus: the status callback
    /// - Returns: `Promise` of `PaymentResult`.
    private func send(_ request: @escaping () throws -> PaxRequest, to device: CCDevice) -> Single<CCResult> {
        return Single.create { single in
            self.queue.async {
                do {
                    // Stupid way of handling parameters from PAX
                    if device.ipAddress != Defaults[UserDefaults.destIP] {
                        Defaults[UserDefaults.destIP] = device.ipAddress
                        Defaults[UserDefaults.destPort] = "10009"
                        Defaults[UserDefaults.timeout] = "60000"
                        Defaults[UserDefaults.commType] = "TCP"
                    }
                    
                    let req = try request()
                    // This will load CommSetting from UserDefaults
                    let link = PosLink()
                    let type = req.set(link: link)
                    guard let result = link.processTrans(type) else {
                        throw CCError.invalidReponse(detail: "Empty response")
                    }
                    switch result.code {
                    case OK:
                        let res = req.get(response: link)
                        single(.success(res))
                    case TIMEOUT:
                        throw CCError.transactionError(detail: "Timeout processing transaction")
                    case ERROR:
                        throw CCError.transactionError(detail: result.msg ?? "Unknown error with code \(result.code.rawValue)")
                    default:
                        throw CCError.transactionError(detail: "Unknown result code: \(result.code.rawValue)")
                    }
                } catch let error {
                    single(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    /// Scan the device for it's IP address.
    ///
    /// - Parameter device: the device to be scan for
    /// - Returns: the Single of the mac address
    private func scan(for device: CCDevice) -> Single<String> {
        return Single.create { single in
            self.queue.async {
                // No need to run on different dispatch queue,
                // cause this is called by the cc request alone
                self.scanner.scan(for: device.macAddress) { (ip, error) in
                    guard let ip = ip, ip.isNotEmpty else {
                        return single(.error(CCError.deviceNotFound))
                    }
                    single(.success(ip))
                }
            }
            return Disposables.create {
                self.scanner.stop()
            }
        }
    }
}

extension UserDefaults {
    static let destIP = DefaultsKey<String?>("destIP")
    static let destPort = DefaultsKey<String?>("destPort")
    static let timeout = DefaultsKey<String?>("timeout")
    static let commType = DefaultsKey<String?>("commType")
}

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
    var cardType: String? { return res.cardType.stringCardType }
    var cvResponse: String? { return res.cvResponse }
    var hostCode: String? { return res.hostCode }
    var hostResponse: String? { return res.hostResponse }
    var message: String? { return res.message }
    var approvedAmount: Double { return toDouble(res.approvedAmount) }
    var refNum: String? { return res.refNum }
    var remainingBalance: Double { return toDouble(res.remainingBalance) }
    var extraBalance: Double { return toDouble(res.extraBalance) }
    var requestedAmount: Double { return toDouble(res.requestedAmount) }
    var resultCode: String { return res.resultCode ?? "" }
    var resultTxt: String { return res.resultTxt ?? "" }
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

fileprivate extension String {
    var stringCardType: String {
        if self == "01" { return "VISA" }
        if self == "02" { return "MASTERCARD" }
        if self == "03" { return "AMEX" }
        if self == "04" { return "DISCOVER" }
        if self == "05" { return "DINERCLUB" }
        if self == "06" { return "ENROUTE" }
        if self == "07" { return "JCB" }
        if self == "08" { return "REVOLUTIONCARD" }
        if self == "09" { return "VISAFLEET" }
        if self == "10" { return "MASTERCARDFLEET" }
        if self == "11" { return "FLEETONE" }
        if self == "12" { return "FLEETWIDE" }
        if self == "13" { return "FUELMAN" }
        if self == "14" { return "GASCARD" }
        if self == "15" { return "VOYAGER" }
        if self == "16" { return "WRIGHTEXPRESS" }
        if self == "99" { return "OTHER" }
        return self
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
    
    var displayCode: String { return "" }
    var displayMessage: String { return "" }
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
    var resultCode: String { return res.resultCode ?? "" }
    var resultTxt: String { return res.resultTxt ?? "" }
}
