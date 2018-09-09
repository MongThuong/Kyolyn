//
//  CCService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// During operationing, there are many phases including finding device and then sending request to device for payment
enum CCStatus {
    /// Request sent to device, awaiting reponse.
    case progress(detail: String)
    /// Request complted with response
    case completed(result: CCResult)
    /// Request complted with response
    case error(error: Error)
}

/// Represent a payment system.
protocol CCService {
    
    /// Request SALE using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - amount: the amount to perform.
    /// - Returns: Promise of a `PaymentResult`.
    func sale(amount: Double, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus>
    
    /// Request REFUND using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - amount: the amount to perform.
    /// - Returns: Promise of a `PaymentResult`.
    func refund(amount: Double, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus>
    
    /// Request FORCE using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - amount: the amount to perform.
    /// - Returns: Promise of a `PaymentResult`.
    func force(amount: Double, using device: CCDevice, byEmployee employee: Employee, with authCode: String) -> Observable<CCStatus>
    
    /// Request ADJUST using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - trans: the transaction to perform on.
    ///   - amount: the amount to perform.
    /// - Returns: Promise of a `PaymentResult`.
    func adjust(trans transID: String, newTipAmount amount: Double, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus>
    
    /// Request VOICE using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    ///   - employee: the `Employee` who performs the request.
    ///   - trans: the transaction to perform on.
    /// - Returns: Promise of a `PaymentResult`.
    func void(trans transID: String, using device: CCDevice, byEmployee employee: Employee) -> Observable<CCStatus>
    
    /// Request CLOSEBATCH using the given device.
    ///
    /// - Parameters:
    ///   - device: the `CCDevice` to send sale command to.
    /// - Returns: Promise of a `BatchResult`.
    func close(batch device: CCDevice) -> Observable<CCStatus>
}
