//
//  TableReportController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit
import ObjectMapper

/// For displaying report in form of Table.
class TableReportController<T: Mappable & Equatable>: DataTableController<ReportQueryResult<T>, T> {
    let filterDate = KLDatePicker()
    let filterShift = KLComboBox<Int>()
    
    let print = KLBarPrimaryRaisedButton()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: TableReportViewModel<T> = TableReportViewModel<T>()) {
        super.init(viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        print.fakIcon = FAKFontAwesome.printIcon(withSize: 16)
        bar.rightViews = [refresh, print]
        
        guard let viewModel = viewModel as? TableReportViewModel<T> else {
            return
        }
        
        filterDate.rx.date
            .asDriver()
            .map { ($0, $0) } // Convert single date to from/to dates
            .drive(viewModel.selectedDate)
            .disposed(by: disposeBag)
        
        viewModel.shifts
            .asDriver()
            .map { $0.map { shift in (shift > 0 ? "Shift \(shift)" : "ALL", shift) } }
            .drive(filterShift.items)
            .disposed(by: disposeBag)
        filterShift.selectedItem
            .asDriver()
            .filterNil()
            .map { $0.1 }
            .distinctUntilChanged()
            .drive(viewModel.selectedShift)
            .disposed(by: disposeBag)
        
        print.rx.tap
            .asDriver()
            .drive(viewModel.print)
            .disposed(by: disposeBag)
    }
}
