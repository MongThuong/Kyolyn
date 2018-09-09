//
//  ServerReportController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For displaying Server report both by Summary or Detail mode.
class ByEmployeeReportController: TableReportController<EmployeeTotalReportRow> {
    fileprivate let filterServer = KLComboBox<String>()
    
    let summaryColumns = [
        KLDataTableColumn<EmployeeTotalReportRow>(name: "SHIFT", type: .number, value: { "\($0.shift)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "SERVER", type: .name, value: { "\($0.name)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "TABLE\nOPENED", type: .largeNumber, lines: 2, value: { "\($0.opening)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "TABLE\nCLOSED", type: .largeNumber, lines: 2, value: { "\($0.closing)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "TIP AMT.", type: .currency, value: { $0.tip.asMoney }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "SALES AMT.", type: .currency, value: { $0.total.asMoney }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "TOTAL AMT.", type: .currency, value: { $0.totalWithTip.asMoney }) ]
    let detailColumns = [
        KLDataTableColumn<EmployeeTotalReportRow>(name: "SHIFT", type: .number, value: { "\($0.order!.shift)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "ORD.#", type: .number, value: { "\($0.order!.orderNo)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "TABLE", type: .name, value: { "\($0.order!.tableName)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "OPENING\nTIME", type: .largeNumber, lines: 2, value: { "\($0.order!.openingTime)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "CLOSING\nTIME", type: .largeNumber, lines: 2, value: { "\($0.order!.closingTime)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "#GST.", type: .number, value: { "\($0.order!.persons)" }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "TIP AMT.", type: .currency, value: { $0.order!.tip.asMoney }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "SALES AMT.", type: .currency, value: { $0.order!.total.asMoney }),
        KLDataTableColumn<EmployeeTotalReportRow>(name: "TOTAL AMT.", type: .currency, value: { $0.order!.totalWithTip.asMoney }) ]
    let summarySummaryCells = [
        KLDataTableSummaryCell(type: .name, value: { _ in "TOTAL" }),
        KLDataTableSummaryCell(type: .number, value: { "\($0.opening)" }),
        KLDataTableSummaryCell(type: .number, value: { "\($0.closing)" }),
        KLDataTableSummaryCell(type: .currency, value: { $0.tip.asMoney }),
        KLDataTableSummaryCell(type: .currency, value: { $0.total.asMoney }),
        KLDataTableSummaryCell(type: .currency, value: { $0.totalWithTip.asMoney }) ]
    let detailSummaryCells = [
        KLDataTableSummaryCell(type: .name, value: { _ in "TOTAL" }),
        KLDataTableSummaryCell(type: .number, value: { "\($0.guests)" }),
        KLDataTableSummaryCell(type: .currency, value: { $0.tip.asMoney }),
        KLDataTableSummaryCell(type: .currency, value: { $0.total.asMoney }),
        KLDataTableSummaryCell(type: .currency, value: { $0.totalWithTip.asMoney }) ]
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: ByEmployeeReportViewModel = ByEmployeeReportViewModel()) {
        super.init(viewModel)
        
        bar.leftViews = [filterDate, filterShift, filterServer]
        
        viewModel.servers
            .asDriver()
            .drive(filterServer.items)
            .disposed(by: disposeBag)
        filterServer.selectedItem
            .asDriver()
            .filterNil()
            .map { $0.1 }
            .distinctUntilChanged()
            .drive(viewModel.selectedServer)
            .disposed(by: disposeBag)
        
        // Change column base on the selected type
        viewModel.selectedServer
            .asDriver()
            .distinctUntilChanged()
            .drive(onNext: { selectedServer in
                if selectedServer.isEmpty {
                    self.columns.accept(self.summaryColumns)
                    self.summaryCells.accept(self.summarySummaryCells)
                } else {
                    self.columns.accept(self.detailColumns)
                    self.summaryCells.accept(self.detailSummaryCells)
                }
            })
            .disposed(by: disposeBag)
    }
}
