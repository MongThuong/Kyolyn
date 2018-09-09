//
//  ByTotalReportViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Total Report.
class ByTotalReportViewModel: TableReportViewModel<TotalReportRow> {

    let totalTypes: [TotalReportType] = [.paymentType, .area]
    let selectedTotalType = BehaviorRelay<TotalReportType>(value: .paymentType)

    override init() {
        super.init()
        selectedTotalType
            .asDriver()
            .filter { _ in self.shouldReload } 
            .distinctUntilChanged()
            .map { _ -> Void in self.calculateDateFilterValues = true }
            .drive(reload)
            .disposed(by: disposeBag)
    }
    
    override func loadData() -> Single<ReportQueryResult<TotalReportRow>> {
        let storeID = self.store.id
        let db = SP.database
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value
        let type = selectedTotalType.value
        
        return db.async {
            switch type {
            case .paymentType:
                let queryResult = db.load(byPaymentTypeReport: storeID, fromDate: fdate, toDate: tdate, shift: shift, includeCardType: true)
                let rows = queryResult.rows
                    .sorted { $0.shift > $1.shift }
                    .sorted { $0.cardType > $1.cardType }
                var finalRows: [PaymentTypeTotalReportRow] = []
                var currentTotalRow: PaymentTypeTotalReportRow?
                // Allocate to new rows
                for r in rows {
                    if r.cardType.isEmpty {
                        finalRows.append(r)
                        currentTotalRow = nil
                        continue
                    }
                    if currentTotalRow == nil || currentTotalRow!.shift != r.shift || currentTotalRow!.transType != r.transType {
                        currentTotalRow = r.clone(without: ["card_type"])
                        finalRows.append(currentTotalRow!)
                    } else {
                        currentTotalRow!.total += r.total
                        currentTotalRow!.tip += r.tip
                        currentTotalRow!.count += r.count
                    }
                    finalRows.append(r)
                }
                return ReportQueryResult(rows: finalRows, summary: queryResult.reportSummary)
            case .area:
                let queryResult = db.load(byAreaReport: storeID, fromDate: fdate, toDate: tdate, shift: shift)
                let rows = queryResult.rows
                    .sorted { $0.shift > $1.shift }
                    .sorted { $0.area > $1.area }
                    .sorted { $0.driver > $1.driver }
                var finalRows: [AreaTotalReportRow] = []
                var currentTotalRow: AreaTotalReportRow?
                // Allocate to new rows
                for r in rows {
                    if currentTotalRow == nil || currentTotalRow!.shift != r.shift || currentTotalRow!.area != r.area {
                        currentTotalRow = r.clone(without: ["driver"])
                        finalRows.append(currentTotalRow!)
                    } else {
                        currentTotalRow!.total += r.total
                        currentTotalRow!.tip += r.tip
                        currentTotalRow!.count += r.count
                    }
                    if r.isDetail { finalRows.append(r) }
                }
                
                return ReportQueryResult(rows: finalRows, summary: queryResult.reportSummary)
            }
        }
    }
    
    override func doPrint(to printer: Printer) -> Single<Void> {
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value

        switch selectedTotalType.value {
        case .paymentType:
            return SP.printingService.print(totalReportByPaymentType: store, fromDate: fdate, toDate: tdate, shift: shift, toPrinter: printer)
        case .area:
            return SP.printingService.print(totalReportByArea: store, fromDate: fdate, toDate: tdate, shift: shift, toPrinter: printer)
        }
    }
}

/// Types of total report
///
/// - paymentType: By payment type.
/// - area: By area.
enum TotalReportType {
    case paymentType
    case area
    
    var displayValue: String {
        switch self {
        case .paymentType:
            return "By Payment Type"
        case .area:
            return "By Area"
        }
    }
}
