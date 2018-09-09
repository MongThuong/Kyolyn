//
//  TransactionReportController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For displaying transaction detail report.
class ByPaymentTypeReportController: TableReportController<TransactionReportRow> {
    fileprivate let filterArea = KLComboBox<String>()
    fileprivate let detail = TransactionView()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: ByPaymentTypeReportViewModel = ByPaymentTypeReportViewModel()) {
        super.init(viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bar.leftViews = [filterDate, filterShift, filterArea]

        guard let viewModel = viewModel as? ByPaymentTypeReportViewModel else {
            return
        }
        
        viewModel.areas
            .asDriver()
            .drive(filterArea.items)
            .disposed(by: disposeBag)
        filterArea.selectedItem
            .asDriver()
            .filterNil()
            .map { $0.1 }
            .distinctUntilChanged()
            .drive(viewModel.selectedArea)
            .disposed(by: disposeBag)
        
        viewModel.selectedRow
            .asDriver()
            .drive(onNext: { row in
                guard let row = row, let order = row.order, let bill = row.bill, let trans = row.transaction else {
                    self.detail.transDetail = nil
                    self.detail.isHidden = true
                    return
                }                
                self.detail.transDetail = (order, bill, trans)
                self.detail.isHidden = false
            })
            .disposed(by: disposeBag)
        
        columns.accept([
            KLDataTableColumn<TransactionReportRow>(name: "SHIFT", type: .number, value: { "\($0.transaction?.shiftIndex ?? 0)" }),
            KLDataTableColumn<TransactionReportRow>(name: "AREA", type: .name, value: { "\($0.order?.areaName ?? "")" }),
            KLDataTableColumn<TransactionReportRow>(name: "ORD.#", type: .number, value: { "\($0.order?.orderNo ?? 0)" }),
            KLDataTableColumn<TransactionReportRow>(name: "TRANS#", type: .largeNumber, value: { "\($0.transaction?.transNum ?? 0)" }),
            KLDataTableColumn<TransactionReportRow>(name: "TRANS TYPE", type: .transType, value: { "\($0.transaction?.displayTransType ?? "")" }),
            KLDataTableColumn<TransactionReportRow>(name: "CARD TYPE", type: .cardType, value: { "\($0.transaction?.displayCardType ?? "")" }),
            KLDataTableColumn<TransactionReportRow>(name: "CARD#", type: .cardNumber, value: { "\($0.transaction?.cardNum ?? "")" }),
            KLDataTableColumn<TransactionReportRow>(name: "TIP AMT.", type: .currency, value: { $0.transaction?.tipAmount.asMoney ?? "" }),
            KLDataTableColumn<TransactionReportRow>(name: "SALES AMT.", type: .currency, value: { $0.transaction?.approvedAmountByStatus.asMoney ?? "" }),
            KLDataTableColumn<TransactionReportRow>(name: "TOTAL AMT.", type: .currency, value: { $0.transaction?.totalWithTipAmount.asMoney ?? "" }),
            ])
        summaryCells.accept([
            KLDataTableSummaryCell(type: .name, value: { _ in "TOTAL" }),
            KLDataTableSummaryCell(type: .currency, value: { $0.tip.asMoney }),
            KLDataTableSummaryCell(type: .currency, value: { $0.total.asMoney }),
            KLDataTableSummaryCell(type: .currency, value: { $0.totalWithTip.asMoney }),
            ])
    }
    
    override func layoutRootView() {
        rootView.axis = .horizontal
        rootView.distribution = .fill
        rootView.alignment = .fill
        rootView.spacing = rootViewMargin
        
        let contentBackgroundView = UIView()
        contentBackgroundView.backgroundColor = theme.cardBackgroundColor
        rootView.addArrangedSubview(contentBackgroundView)

        contentBackgroundView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        detail.isHidden = true
        detail.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rootView.addArrangedSubview(detail)
        detail.snp.makeConstraints { make in
            make.width.equalTo(self.theme.billViewWidth)
        }
    }
}

