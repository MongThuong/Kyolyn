//
//  PrintItemsDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/17/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AwaitKit

/// Base class for all printing related dialog.
class PrintDVM<PJ: PrintingJob, DR>: DialogViewModel<DR> {
    /// The jobs to be performed
    let jobs = BehaviorRelay<[PJ]>(value: [])
    /// Subscribe to get notified when jobs got changed.
    var jobsChanged = PublishSubject<Void>()
    /// Publish to skip the printing
    let skip = PublishSubject<Void>()
    /// Publish to start printing
    let print = PublishSubject<PJ>()
    
    /// True to show skip button
    var allowSkipping: Bool { return true }
    
    override init() {
        super.init()
        // Create jobs upon showing
        dialogDidAppear
            .flatMap { _ -> Single<[PJ]> in
                async { try self.createPrintingJobs() }
            }
            .bind(to: jobs)
            .disposed(by: disposeBag)

        // starting printing
        print
            .subscribe(onNext: { self.print(job: $0) })
            .disposed(by: disposeBag)

        // Assume everything got printed
        skip
            .map { self.skipPrintingResult }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)

    }
    
    /// Override to provide the printing jobs.
    ///
    /// - Returns: The list of printing job.
    func createPrintingJobs() throws -> [PJ] {
        return []
    }
    
    /// Override to perform printing on a job.
    ///
    /// - Parameter job: The job to print.
    func print(job: PJ) {
        let status = job.status
        // Make sure it won't print twice
        guard status.value.isNotLoading, !isClosed else {
            return
        }
        // Mark as loading
        status.accept(.loading)
        jobsChanged.onNext(())
        DispatchQueue.global(qos: .background).async {
            _ = self.doPrint(job)
                .subscribe(onSuccess: { _ in
                    // Make sure it won't processed anything after printing
                    guard !self.isClosed else { return }
                    status.accept(.ok)
                    self.jobsChanged.onNext(())
                }, onError: { error in
                    // Make sure it won't processed anything after printing
                    guard !self.isClosed else { return }
                    if let error = error as? PrintError {
                        e("PRINTING ERROR: \(error.localizedDescription) (Printer: \(job.printer)")
                        status.accept(.error(reason: error.localizedDescription))
                    }
                    self.jobsChanged.onNext(())
                })
        }
    }

    /// Truely perform the printing.
    ///
    /// - Parameter job: The job to perform.
    /// - Returns: Promise of printing result.
    func doPrint(_ job: PJ) -> Single<Void> {
        fatalError("Child class must provide implementation")
    }

    /// Override to provide skip printing logic.
    ///
    /// - Returns: The dialog result.
    var skipPrintingResult: DR? {
        return nil
    }
}
