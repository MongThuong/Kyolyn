//
//  EmailService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 9/15/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Main interface for printing service.
class EmailService {
    
    /// Send voiding `Transaction` email.
    ///
    /// - Parameters:
    ///   - store: the `Store`.
    ///   - employee: the `Employee` who void the transaction.
    ///   - transaction: the voided `Transction`.
    ///   - reason: the reason for voiding.
    /// - Returns: Promise of sending result
    final func send(voidTransaction transaction: Transaction, inStore store: Store, byEmployee employee: Employee, with reason: String) -> Single<()> {
        let body = "Trans#: \(transaction.transNum)\nEmployee: \(employee.name)\nID: \(employee.id)\nAmount: \(transaction.approvedAmount.asMoney)\nReason: \(reason)"
        return send(email: store.bizEmail, withBody: body, andTitle: "Transaction \(transaction.transNum) has been voided")
    }

    /// Send voiding `Order` email.
    ///
    /// - Parameters:
    ///   - store: the `Store`.
    ///   - employee: the `Employee` who void the transaction.
    ///   - order: the voided `Order`.
    ///   - reason: the reason for voiding.
    /// - Returns: Promise of sending result
    final func send(voidOrder order: Order, inStore store: Store, byEmployee employee: Employee,  with reason: String) -> Single<()> {
        let body = "Employee: \(employee.name)\nID: \(employee.id)\nReason: \(reason)\nOrder#: \(order.orderNo)\nTotal: \(order.total.asMoney)";
        return send(email: store.bizEmail, withBody: body, andTitle: "Order \(order.orderNo) has been voided")
    }
    
//    /// Send log file back to developer
//    ///
//    /// - Returns: <#return value description#>
//    func sendLogFile() -> Single<()>{
//                do {
//                    let logFile = NSTemporaryDirectory().appending("kiolyn.log")
//                    let logData = try Data(contentsOf: URL(fileURLWithPath: logFile))
//                    mail.addAttachmentData(logData, mimeType: "text/txt", fileName: "kiolyn.log")
//                } catch {
//                    derror("Could not read log file.")
//                }
//        
//
//        let body = "Employee: \(employee.name)\nID: \(employee.id)\nReason: \(reason)\nOrder#: \(order.orderNo)\nTotal: \(order.total.asMoney)";
//        return send(email: "chinh.nguyen@willbe.vn", withBody: body, andTitle: "Order \(order.orderNo) has been voided")
//    }
    
    /// Real email sending, default to logging.
    ///
    /// - Parameters:
    ///   - email: the target receiver.
    ///   - body: the email body.
    ///   - title: the email title.
    /// - Returns: Single of the sending result.
    func send(email: String, withBody body: String, andTitle title: String) -> Single<()> {
        d("[EMAIL-VOID-ORDER]")
        d("[TO] \(email)")
        d("[BODY] \(body)")
        return Single.just(())
    }
}
