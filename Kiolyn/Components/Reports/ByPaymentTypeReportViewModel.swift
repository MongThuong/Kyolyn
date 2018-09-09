//
//  TransactionReportViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Transaction detail Report
class ByPaymentTypeReportViewModel: TableReportViewModel<TransactionReportRow> {
    // Area filter
    let allArea: String = ""
    let areas = BehaviorRelay<[(String, String)]>(value: [])
    let selectedArea = BehaviorRelay<String>(value: "")
    
    override init() {
        super.init()
        selectedArea
            .asDriver()
            .filter { _ in self.shouldReload }
            .distinctUntilChanged()
            .map { _ -> Void in self.calculateDateFilterValues = false }
            .drive(reload)
            .disposed(by: disposeBag)
    }
    
    override func loadData() -> Single<ReportQueryResult<TransactionReportRow>> {
        let storeID = self.store.id
        let db = SP.database
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value
        let area = selectedArea.value
        let page = self.page.value
        let pageSize = self.pageSize.value
        return db.async {
            db.load(transactions: storeID, fromDate: fdate, toDate: tdate, shift: shift, area: area, page: page, pageSize: pageSize)
        }
    }
    
    override func update(filter summary: ReportQuerySummary) {
        super.update(filter: summary)
        areas.accept(
            [("ALL", self.allArea)] +
            summary.areas.map { id -> (String, String) in
                guard let area: Area = SP.database.load(id) else {
                    return ("NOT FOUND", id)
                }
                return (area.name.uppercased(), id)
        })
        selectedArea.accept(areas.value.first!.1)
    }
    
    override func doPrint(to printer: Printer) -> PrimitiveSequence<SingleTrait, Void> {
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value
        let area = selectedArea.value
        return SP.printingService.print(byPaymentTypeReport: store, fromDate: fdate, toDate: tdate, shift: shift, area: area, toPrinter: printer)
    }
}

