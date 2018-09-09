//
//  CloseBatchDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 10/14/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// A single printing job.
class CloseBatchJob {
    let device: CCDevice?
    let transactions: [Transaction]
    var status = BehaviorRelay<ViewStatus>(value: .none)
    init(device: CCDevice?, transactions: [Transaction]) {
        self.device = device
        self.transactions = transactions
    }
}

/// For closing batch.
class CloseBatchDVM: DialogViewModel<()> {
    let jobs = BehaviorRelay<[CloseBatchJob]>(value: [])
    let jobsChanged = PublishSubject<Void>()
    let status = BehaviorRelay<ViewStatus>(value: .none)
    let settle = PublishSubject<Void>()
    let request = PublishSubject<CloseBatchJob>()

    override var dialogResult: ()? {
        return ()
    }
    
    override init() {
        super.init()
        
        dialogTitle.accept("Closing Batch")
        
        _ = dialogDidAppear
            .flatMap { _ -> Single<[CloseBatchJob]> in
                let db = SP.database
                self.status.accept(.loading)
                return db
                    .async {
                        db.load(unsettledTransactions: self.store.id)
                            .group { trans in trans.paymentDevice }
                            .map { (deviceID, transactions) -> CloseBatchJob in
                                let device: CCDevice? = db.load(deviceID)
                                return CloseBatchJob(device: device, transactions: transactions)
                        }
                    }
                    .catchError { error -> Single<[CloseBatchJob]> in
                        self.status.accept(ViewStatus.error(reason: error.localizedDescription))
                        return Single.just([])
                    }
                    .map { jobs in
                        self.status.accept(.ok)
                        return jobs
                }
            }
            .bind(to: jobs)
        
        // Start all jobs when created
        jobs.asDriver()
            .drive(onNext: { jobs in
                for job in jobs {
                    self.request(job: job)
                }
            })
            .disposed(by: disposeBag)
        
        request
            .subscribe(onNext: { job in self.request(job: job) })
            .disposed(by: disposeBag)

        settle
            .flatMap { require(permission: Permissions.REFUND_VOID_UNPAID_SETTLE) }
            .filterNil()
            .withLatestFrom(jobs)
            .subscribe(onNext: { jobs in
                for job in jobs {
                    guard job.status.value.isNotOK else {
                        continue
                    }
                    let status = job.status
                    _ = self.settle(job: job)
                        .subscribe(onSuccess: { _ in
                            status.accept(.ok)
                            self.jobsChanged.onNext(())
                        }, onError: { error in
                            status.accept(.error(reason: error.localizedDescription))
                            self.jobsChanged.onNext(())
                        })
                }
            })
            .disposed(by: disposeBag)

    }

    /// Settle transactions with given device (nil for Cash/Custom) and the batch result.
    ///
    /// - Parameters:
    ///   - transactions: the list of `Transaction` to settle.
    ///   - device: the `CCDevice` to settle.
    ///   - result: the `BatchResult`.
    fileprivate func settle(job: CloseBatchJob, with result: BatchResult? = nil) -> Single<Transaction?> {
        guard let shift = dataService.activeShift.value, job.transactions.isNotEmpty else {
            return Single.just(nil)
        }
        let db = SP.database
        return db.async {
            // List of objects to be saved
            var savingObjects: [BaseModel] = []
            // The batch transaction itself
            let settlingTrans = Transaction(forCloseBatch: self.store, forShift: shift, byEmployee: self.employee, ccDevice: job.device, result: result, settledTrans: job.transactions)
            savingObjects.append(settlingTrans)
            // Settle all transactions
            for trans in job.transactions {
                _ = trans.settle(by: settlingTrans, by: self.employee)
                savingObjects.append(trans)
                // Check if the Order is already added to list
                var order: Order? = savingObjects.first(where: { $0.id == trans.order }) as? Order
                if order == nil {
                    // Not found in added list, get from database
                    order = db.load(trans.order)
                    // not found in db, means something is wrong, skip it
                    if order == nil { continue }
                    savingObjects.append(order!)
                }
                // Settle any matching bill
                if let bill = order?.bills.first(where: { $0.id == trans.bill }) {
                    bill.settled = true
                }
            }
            // Save settling trans + settled trans(es) + Orders/Bills
            try db.save(all: savingObjects)
            // Print it
            if let printer = self.defaultPrinter {
                DispatchQueue.global(qos: .background).async {
                    _ = SP.printingService
                        .print(closeBatchReport: (job.device, job.transactions, settlingTrans), store: self.store, byServer: self.employee, shift: shift, toPrinter: printer)
                        .subscribe()
                }
            }            
            return settlingTrans
        }
    }

    /// Either settle for non-card trans or sending close batch command
    /// to CCDevice for settling.
    ///
    /// - Parameter job: the `CloseBatchJob`.
    fileprivate func request(job: CloseBatchJob) {
        let status = job.status
        // Make sure it won't print twice
        guard status.value.isNotLoading, status.value.isNotOK, !isClosed else {
            return
        }
        // Mark as loading
        status.accept(.loading)
        jobsChanged.onNext(())
        // No device or Standalone CCDevice can settle right away
        guard let device = job.device, device.isNotStandalone else {
            let result = NonCardBatchResult(transactions: job.transactions)
            _ = settle(job: job, with: result)
                .subscribe(onSuccess: { _ in
                    status.accept(.ok)
                    self.jobsChanged.onNext(())
                }, onError: { error in
                    status.accept(.error(reason: error.localizedDescription))
                    self.jobsChanged.onNext(())
                })
            return
        }
        
        _  = SP.ccService
            .close(batch: device)
            .map { ccStatus -> BatchResult? in
                switch ccStatus {
                case let .progress(detail):
                    status.accept(.message(m: detail))
                    return nil
                case let .error(error):
                    status.accept(.error(reason: error.localizedDescription))
                    self.jobsChanged.onNext(())
                    return nil
                case let .completed(result):
                    guard let batchResult = result as? BatchResult else {
                        status.accept(.error(reason: "Not a batch result"))
                        self.jobsChanged.onNext(())
                        return nil
                    }
                    return batchResult
                }
            }
            .filterNil()
            .flatMap { batchResult in self.settle(job: job, with: batchResult) }
            .subscribe(onNext: { _ in
                status.accept(.ok)
                self.jobsChanged.onNext(())
            }, onError: { error in
                status.accept(.error(reason: error.localizedDescription))
                self.jobsChanged.onNext(())
            })
    }
}
