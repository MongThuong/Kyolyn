//
//  ReportsViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/1/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

/// Base class for all table reports.
class TableReportViewModel<T: Mappable>: DataTableViewModel<ReportQueryResult<T>, T> {
    // Date filter
    let selectedDate = BehaviorRelay<(Date, Date)>(value: (Date(), Date()))

    // Shift filter
    let allShift: Int = 0
    let shifts = BehaviorRelay<[Int]>(value: [])
    let selectedShift = BehaviorRelay<Int>(value: 0)

    // Calculate filters
    var calculateDateFilterValues = true

    // To stop reloading while updating filter value programmatically
    var shouldReload = false

    // Action
    let print = PublishSubject<Void>()

    override init() {
        super.init()

        selectedDate
            .asDriver()
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                return lhs.0 == rhs.0 && lhs.1 == rhs.1
            }
            .debounce(0.001) // Make sure we don't load too much
            .map { _ -> Void in self.calculateDateFilterValues = true }
            .drive(reload)
            .disposed(by: disposeBag)

        selectedShift
            .asDriver()
            .filter { _ in self.shouldReload }
            .distinctUntilChanged()
            .skip(1)
            .map { _ -> Void in self.calculateDateFilterValues = false }
            .drive(reload)
            .disposed(by: disposeBag)

        data
            .asDriver()
            .filter { _ in self.calculateDateFilterValues }
            .drive(onNext: { queryResult in
                self.shouldReload = false
                self.update(filter: queryResult.reportSummary)
                self.shouldReload = true
                self.calculateDateFilterValues = true
            })
            .disposed(by: disposeBag)

        print
            .flatMap { dmodal { PrintSingleDVM(self.doPrint) } }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func update(filter summary: ReportQuerySummary) {
        shifts.accept([allShift] + summary.shifts)
        selectedShift.accept(allShift)
    }

    func doPrint(to printer: Printer) -> Single<Void> {
        return Single.just(())
    }
}

