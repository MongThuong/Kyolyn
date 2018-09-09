//
//  BusinessLogics+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// The result of payment dialog.
/// 1. The selected payment type (CASH, CREDIT, CUSTOM)
/// 2. The amount of payment
/// 3. The sub payment type
typealias PayBillInfo = (Order, Bill, PaymentType, Double, PaymentType?)


/// Pay bill with pay info.
///
/// - Parameter payInfo: pay info.
/// - Returns: Single of the payment result.
func pay(bill payInfo: PayBillInfo) -> Single<Order?> {
    let ds = SP.dataService
    guard let id = SP.authService.currentIdentity.value,
        let _ = ds.activeShift.value else {
            return Single.just(nil)
    }
    
    let (order, bill, type, amount, subType) = payInfo
    let paidAmount = min(amount, bill.totalWithTip) - bill.tip
    return modify(order: order, "payBill") { order in
        var getTrans: Single<Transaction?>!
        if type is CardPaymentType {
            let ccDeviceID = id.station.ccdevice
            guard ccDeviceID.isNotEmpty else {
                derror("Please configure credit card device for this Station.")
                return Single.just(nil)
            }
            let loadDevice: Single<CCDevice?> = ds.load(ccDeviceID)
            getTrans = loadDevice
                .catchError { error -> Single<CCDevice?> in
                    derror("Could not load Credit Card device associated with this Station.")
                    return Single.just(nil)
                }
                .asObservable()
                .filterNil()
                .flatMap { device in
                    dmodal { CreditSaleDVM(device, order: order, bill: bill, amount: paidAmount, subPaymentType: subType) }
                }
                .asSingle()
        } else {
            getTrans = ds.increase(counter: .transNo)
                .map { shift throws -> Transaction? in
                    guard let shift = shift else {
                        return nil
                    }
                    
                    if type is CashPaymentType {
                        return Transaction(forCash: id.store, forShift: shift, byEmployee: id.employee, order: order, bill: bill, amount: paidAmount, subPaymentType: subType)
                    } else {
                        return Transaction(forCustom: id.store, forShift: shift, byEmployee: id.employee, order: order, bill: bill, amount: paidAmount, paymentType: type, subPaymentType: subType)
                    }
            }
        }
        
        return getTrans
            .catchError{ error -> Single<Transaction?> in
                derror(error) // Show the error
                return Single.just(nil) // Stop the flow
            }
            .asObservable()
            .filterNil()
            .save()
            .map { trans -> Order in
                // Pay and display message (if any)
                if let message = order.pay(bill: bill, with: trans, by: id.employee) {
                    dinfo(message)
                }
                return order
            }
            .asSingle()
    }
}

/// Send void transaction email to owner.
///
/// - Parameters:
///   - trans: the transaction to be voided
///   - reason: the voiding reason.
/// - Returns: Single of the result.
fileprivate func send(voidingTransEmail trans: Transaction, withReason reason: String) {
    let auth = SP.authService
    guard let employee = auth.employee, let store = auth.store else {
        return
    }
    d("VOIDING TRANSACTION \(trans) APPROVED BY \(employee) REASON \(reason)")
    // Have a good reason, now start sending mail
    // Truely send email here - we don't care about the result
    // We just fire and forget, don't care about the result (it will get logged)    
    _ = SP.emailService
        .send(voidTransaction: trans, inStore: store, byEmployee: employee, with: reason)
        .subscribe()
}

fileprivate func doVoid(transaction trans: Transaction, withOrder order: Order?, andReason reason: String, byEmployee employee: Employee) -> Single<Transaction?> {
    let ds = SP.dataService
    guard let trans = trans.void(with: reason, by: employee) else {
        return Single.just(nil)
    }
    var saving: Single<Transaction?>
    if let order = order, let bill = order.bills.first(where: { bill in
        bill.transaction == trans.id && bill.paid }) {
        _ = order.void(bill: bill)
        saving = ds.save(all: [trans, order]).map { _ -> Transaction? in trans }
    } else {
        saving = ds.save(trans).map { trans -> Transaction? in trans }
    }
    return saving.catchError { error -> Single<Transaction?> in
        derror(error)
        return Single.just(nil)
    }
}

/// Void a transaction.
///
/// - Parameter trans: the transaction to void.
/// - Returns: the Single of voiding result
func void(transaction trans: Transaction, withOrder order: Order? = nil) -> Single<Transaction?> {
    let ds = SP.dataService
    guard let id = SP.authService.currentIdentity.value,
        let _ = ds.activeShift.value else {
            return Single.just(nil)
    }
    if trans.hasPaymentDevice {
        let loadDevice: Single<CCDevice?> = ds.load(trans.paymentDevice)
        return loadDevice
            .catchError { error -> Single<CCDevice?> in
                derror("Transaction's Credit Card device could not be found.")
                return Single.just(nil)
            }
            .asObservable()
            .filterNil()
            .flatMap { device in
                dmodal { SelectAndEditReasonDVM(id.settings.voidTransactionReasons) }
                    .flatMap { reason -> Single<Transaction?> in
                        guard let reason = reason, reason.isNotEmpty else {
                            return Single.just(nil)
                        }
                        send(voidingTransEmail: trans, withReason: reason)
                        return dprogress("Sending notification to Owner, please wait...", timeout: 2)
                            .flatMap { _ in
                                dmodal { CreditVoidDVM(device, for: trans, with: reason) }
                                    .flatMap { trans -> Single<Transaction?> in
                                        guard let trans = trans else {
                                            return Single.just(nil)
                                        }
                                        return doVoid(transaction: trans, withOrder: order, andReason: reason, byEmployee: id.employee)
                                }
                        }
                }
            }
            .asSingle()
    } else {
        return dmodal { SelectAndEditReasonDVM(id.settings.voidTransactionReasons) }
            .flatMap { reason -> Single<Transaction?> in
                guard let reason = reason, reason.isNotEmpty else {
                    return Single.just(nil)
                }
                send(voidingTransEmail: trans, withReason: reason)
                return dprogress("Sending notification to Owner, please wait...", timeout: 2)
                    .flatMap { _ in
                        doVoid(transaction: trans, withOrder: order, andReason: reason, byEmployee: id.employee)
                }
            }
    }
}
