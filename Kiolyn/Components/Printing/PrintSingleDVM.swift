//
//  PrintSingleDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AwaitKit

typealias PrintSingle = (Printer) -> Single<Void>

/// For printing Report.
class PrintSingleDVM: PrintDVM<PrintingJob, Void> {
    
    override var allowSkipping: Bool {
        return false
    }
    
    let printFunc: PrintSingle
    init(_ print: @escaping PrintSingle) {
        printFunc = print
        super.init()
        dialogTitle.accept("Printing ...")
        // If there is a printer
        jobs
            .asObservable()
            .subscribe(onNext: { jobs in
                if let job = jobs.first(where: { $0.printer.id == self.defaultPrinter?.id }) {
                    self.print(job: job)
                }
            })
            .disposed(by: disposeBag)
        jobsChanged
            .filter { self.jobs.value.any({ $0.status.value.isOK }) }
            .map { self.dialogResult }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
    
    override func createPrintingJobs() throws -> [PrintingJob] {
        let printers: [Printer] = try await(dataService.loadAll())
        return printers
            .filter { printer in printer.isValid }
            .map { printer in PrintingJob(printer) }
    }

    override func doPrint(_ job: PrintingJob) -> Single<Void> {
        return printFunc(job.printer)
    }
}
