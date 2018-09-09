//
//  ShiftAndDayReportController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For displaying Shift&Day Report.
class ByShiftAndDayReportController: TableReportController<NameValueReportRow> {
    fileprivate let filterDateRange = KLComboBox<DateRange>()
    fileprivate let filterFromDate = KLDatePicker()
    fileprivate let filterToDate = KLDatePicker()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: ByShiftAndDayReportViewModel = ByShiftAndDayReportViewModel()) {
        super.init(viewModel)
        columns.accept([
            KLDataTableColumn<NameValueReportRow>(name: "", type: .name, value: { "\($0.name)" }, format: self.format),
            KLDataTableColumn<NameValueReportRow>(name: "", type: .currency, value: { "\($0.value)" }, format: self.format) ])
    }
    
    override func setupDataTable() {
        super.setupDataTable()
        table.snp.remakeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.header.isHidden = true
        table.summary.isHidden = true
        table.pagination.isHidden = true
        table.table.rowHeight = theme.smallButtonHeight
        
        bar.leftViews = [filterDateRange, filterFromDate, filterToDate, filterShift]
        
        guard let viewModel = viewModel as? ByShiftAndDayReportViewModel else {
            return
        }
        
        Driver
            .just(DateRange.all)
            .map { ranges in ranges.map { range in (range.displayName, range) } }
            .drive(filterDateRange.items)
            .disposed(by: disposeBag)
        filterDateRange.selectedItem
            .asDriver()
            .filterNil()
            .map { _, selectedDate in selectedDate }
            .distinctUntilChanged()
            .map { selectedDate in selectedDate.dateRange }
            .filterNil()
            .drive(onNext: { fromDate, toDate in
                //                self.filterDateRange.selectedItem.value = self.filterDateRange.items.value.last
                //                let fdate = self.filterFromDate.date.value
                //                let tdate = self.filterToDate.date.value
                //                if fdate > tdate {
                //                    if type == "fdate" {
                //                        self.filterToDate.date.value = fdate
                //                    } else {
                //                        self.filterFromDate.date.value = tdate
                //                    }
                //                }
                //                viewModel.selectedDate.value = (self.filterFromDate.date.value, self.filterToDate.date.value)
                self.filterFromDate.date = fromDate
                self.filterToDate.date = toDate
            })
            .disposed(by: disposeBag)

        Driver.combineLatest(
            filterFromDate.rx.date.asDriver().distinctUntilChanged(),
            filterToDate.rx.date.asDriver().distinctUntilChanged())
            .drive(viewModel.selectedDate)
            .disposed(by: disposeBag)
    }
    
    private func format(_ row: NameValueReportRow, _ cell: UIView, _ disposeBag: DisposeBag) {
        guard let label = cell as? UILabel else { return }
        switch row.rowType {
        case "superhighlight":
            label.font = theme.heading2BoldFont
            label.alpha = 1
        case "highlight":
            label.font = theme.heading3BoldFont
            label.alpha = 1
        case "formula":
            label.font = theme.normalItalicFont
            label.alpha = 0.5
        case "sub":
            label.font = theme.smallFont
            label.alpha = 0.8
        default: // case "normal"
            label.font = theme.normalFont
            label.alpha = 0.8
        }
    }
}
