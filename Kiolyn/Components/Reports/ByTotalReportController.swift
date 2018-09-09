//
//  TotalReportController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For displaying Total report both by Payment Type and Area.
class ByTotalReportController: TableReportController<TotalReportRow> {
    let filterTotalType = KLComboBox<TotalReportType>()
    
    let byPaymentTypeColumns = [
        KLDataTableColumn<TotalReportRow>(name: "SHIFT", type: .number, value: { "\($0.shift)" }),
        KLDataTableColumn<TotalReportRow>(name: "TRANS TYPE", type: .name, value: { "\(($0 as? PaymentTypeTotalReportRow)?.displayName ?? "")" }),
        KLDataTableColumn<TotalReportRow>(name: "#TRANS", type: .largeNumber, value: { "\($0.count)" }),
        KLDataTableColumn<TotalReportRow>(name: "TIP AMT.", type: .currency, value: { $0.tip.asMoney }),
        KLDataTableColumn<TotalReportRow>(name: "SALES AMT.", type: .currency, value: { $0.total.asMoney }),
        KLDataTableColumn<TotalReportRow>(name: "TOTAL AMT.", type: .currency, value: { $0.totalWithTip.asMoney }) ]
    
    let byAreaColumns = [
        KLDataTableColumn<TotalReportRow>(name: "SHIFT", type: .number, value: { "\($0.shift)" }),
        KLDataTableColumn<TotalReportRow>(name: "AREA", type: .name, value: { "\(($0 as? AreaTotalReportRow)?.displayName ?? "")" }),
        KLDataTableColumn<TotalReportRow>(name: "#ORD.", type: .number, value: { "\($0.count)" }),
        KLDataTableColumn<TotalReportRow>(name: "TIP AMT.", type: .currency, value: { $0.tip.asMoney }),
        KLDataTableColumn<TotalReportRow>(name: "SALES AMT.", type: .currency, value: { $0.total.asMoney }),
        KLDataTableColumn<TotalReportRow>(name: "TOTAL AMT.", type: .currency, value: { $0.totalWithTip.asMoney }) ]
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: ByTotalReportViewModel = ByTotalReportViewModel()) {
        super.init(viewModel)
        
        // No need for pagination
        table.pagination.isHidden = true
        
        bar.leftViews = [filterDate, filterShift, filterTotalType]
        
        Driver.just(viewModel.totalTypes)
            .map { types in types.map { type in (type.displayValue, type) } }
            .drive(filterTotalType.items)
            .disposed(by: disposeBag)
        filterTotalType.selectedItem
            .asDriver()
            .filterNil()
            .map { $0.1 }
            .distinctUntilChanged()
            .drive(viewModel.selectedTotalType)
            .disposed(by: disposeBag)
        
        viewModel.selectedTotalType
            .asDriver()
            .distinctUntilChanged()
            .map { type in
                switch type {
                case .paymentType: return self.byPaymentTypeColumns
                case .area: return self.byAreaColumns
                }
            }
            .drive(columns)
            .disposed(by: disposeBag)
        summaryCells.accept([
            KLDataTableSummaryCell(type: .name, value: { _ in "TOTAL" }),
            KLDataTableSummaryCell(type: .number, value: { "\($0.count)" }),
            KLDataTableSummaryCell(type: .currency, value: { $0.tip.asMoney }),
            KLDataTableSummaryCell(type: .currency, value: { $0.total.asMoney }),
            KLDataTableSummaryCell(type: .currency, value: { $0.totalWithTip.asMoney }) ])
    }
}
