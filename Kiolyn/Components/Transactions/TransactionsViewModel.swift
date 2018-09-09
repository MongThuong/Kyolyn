//
//  TransactionsViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/17/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AwaitKit

/// For handling Transactions list related business.
class TransactionsViewModel: CommonDataTableViewModel<Transaction> {
    
    var paymentTypes: BehaviorRelay<[(String, String)]>!
    let selectedPaymentType = BehaviorRelay<String>(value: "")
    
    let edit = PublishSubject<Void>()
    
    let printCheck = PublishSubject<Void>()
    let printReceipt = PublishSubject<Void>()
    
    let void = PublishSubject<Void>()
    
    let lockOrderVoidTrans = PublishSubject<(Transaction, Order)>()
    
    let closeBatch = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        var types = [("ALL", "")]
        // CASH
        types.append(("CASH", TransactionType.cash.rawValue))
        for t in settings.cashSubPaymentTypes {
            types.append(("CASH - \(t.name.uppercased())", "\(TransactionType.cash.rawValue)$\(t.id)"))
        }
        // CREDIT
        types.append(("CREDIT", TransactionType.creditSale.rawValue))
        for t in settings.cardSubPaymentTypes {
            types.append(("CREDIT - \(t.name.uppercased())", "\(TransactionType.creditSale.rawValue)$\(t.id)"))
        }
        // OTHERS
        types.append(("VOID", TransactionType.creditVoid.rawValue))
        types.append(("FORCE", TransactionType.creditForce.rawValue))
        types.append(("REFUND", TransactionType.creditRefund.rawValue))
        // CUSTOM
        for t in settings.paymentTypes {
            types.append(("\(t.name.uppercased())", "\(TransactionType.custom.rawValue)$\(t.id)"))
            for st in t.subPaymentTypes {
                types.append(("\(t.name.uppercased()) - \(st.name.uppercased())", "\(TransactionType.custom.rawValue)$\(t.id)$\(st.id)"))
            }
        }
        paymentTypes = BehaviorRelay<[(String, String)]>(value: types)
                
        // Reload on changes
        selectedPaymentType
            .asObservable()
            .distinctUntilChanged()
            .mapToVoid()
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        // For KIO-263: Edit Transaction Dialog
        edit
            .withLatestFrom(selectedRow.asObservable())
            .filterNil()
            .filter { $0.transStatus == .new }
            .modal { EditSubPaymentDVM($0) }
            .mapToVoid()
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        printCheck
            .withLatestFrom(selectedRow)
            .filterNil()
            .flatMap { trans in
                dmodal { PrintBillDVM(transaction: trans, type: .check) }
            }
            .subscribe()
            .disposed(by: disposeBag)

        printReceipt
            .withLatestFrom(selectedRow)
            .filterNil()
            .flatMap { trans in
                dmodal { PrintBillDVM(transaction: trans, type: .receipt) }
            }
            .subscribe()
            .disposed(by: disposeBag)

        void
            .flatMap { _ in require(permission: Permissions.REFUND_VOID_UNPAID_SETTLE) }
            .filterNil()
            .withLatestFrom(selectedRow)
            .filterNil()
            .filter { trans in trans.canVoid }
            .flatMap { trans -> Single<(Transaction, Order?)> in
                guard trans.transType.hasCheck else {
                    return Single.just((trans, nil))
                }
                // Try loading order/bill
                guard trans.order.isNotEmpty, trans.bill.isNotEmpty else {
                    return Single.just((trans, nil))
                }
                return self.dataService.load(trans.order)
                    .map { order in (trans, order) }
            }
            .flatMap { (trans, order) in Kiolyn.void(transaction: trans, withOrder: order) }
            .mapToVoid()
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        closeBatch
            .confirm("Do you want to close all transactions?")
            .withLatestFrom(dataService.lockedOrders)
            .filter { lockedOrders in
                guard lockedOrders.isEmpty else {
                    derror("Please unlock all Orders on other stations before closing batch.")
                    return false
                }
                return true
            }
            .flatMap { _ -> Single<()?> in
                dmodal { CloseBatchDVM() }
            }
            .filterNil()
            .mapToVoid()
            .bind(to: reload)
            .disposed(by: disposeBag)
    }
    
    override func loadData() -> Single<QueryResult<Transaction>> {
        // Make sure shift is good
        guard let shift = self.dataService.activeShift.value?.id else {
            return Single.just(QueryResult<Transaction>())
        }
        let storeID = store.id
        let paymentType = selectedPaymentType.value
        let page = self.page.value
        let pageSize = self.pageSize.value
        let db = SP.database
        return db.async {
            db.load(unsettledTransactions: storeID, shift: shift, for: paymentType, page: page, pageSize: pageSize)
        }
    }
    
    /// Adjust tip for a transaction.
    ///
    /// - Parameters:
    ///   - tip: the tip amount to be adjusted.
    ///   - trans: the transaction to be adjusted.
    /// - Returns: Observable of the adjusting status.
    func adjust(tip: Double, for trans: Transaction) -> Observable<ViewStatus> {
        let ds = SP.dataService
        guard let emp = SP.dataService.id?.employee,
            trans.canAdjust, trans.tipAmount != tip else {
            return Observable.empty()
        }
        if trans.hasPaymentDevice {
            guard trans.refNum.isNotEmpty else {
                return Observable.just(.error(reason: "Transaction does not have RefNum."))
            }
        }
        return Observable.create { observer -> Disposable in
            async {
                i("Adjusting tip for trans #\(trans.transNum)")
                observer.onNext(.loading)
                
                let adjustAndSave = { (order: Order?) in
                    do {
                        let trans = trans.adjust(tip: tip, by: self.employee)
                        if let order = order {
                            _ = try await(lock(andModify: order, "adjustTip") { order in
                                guard let bill = order.bills.first(where: { bill in bill.id == trans.bill }) else {
                                    return Single.just(nil)
                                }
                                bill.tip = tip
                                return ds.save(trans).map { _ in order }
                            })
                        } else {
                            _ = try await(ds.save(trans))
                        }
                        observer.onNext(.ok)
                    } catch let error {
                        observer.onNext(.error(reason: error.localizedDescription))
                    }
                    observer.onCompleted()
                }
                
                do {
                    let order: Order? = try await(ds.load(trans.order))
                    guard trans.hasPaymentDevice else {
                        return adjustAndSave(order)
                    }
                    guard let device: CCDevice = try await(ds.load(trans.paymentDevice)) else {
                        throw CCError.deviceNotFound
                    }
                    _ = SP.ccService
                        .adjust(trans: trans.refNum, newTipAmount: tip, using: device, byEmployee: emp)
                        .subscribe(onNext: { status in
                            switch status {
                            case .completed(_):
                                adjustAndSave(order)
                            case let .error(error):
                                observer.onNext(.error(reason: error.localizedDescription))
                                observer.onCompleted()
                            default: return
                            }
                        })
                } catch let error {
                    observer.onNext(.error(reason: error.localizedDescription))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
