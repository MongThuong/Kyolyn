//
//  OrdersController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// Handling the displaying of Orders.
class OrdersController: CommonDataTableController<Order> {
    override var rootViewMargin: CGFloat {
        return 0
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: OrdersViewModel = OrdersViewModel()) {
        super.init(viewModel)
        columns.accept([
            KLDataTableColumn<Order>(name: "", type: .lockIcon, value: { _ in "" }),
            KLDataTableColumn<Order>(name: "ORD.#", type: .number, value: { "\($0.orderNo)" }),
            KLDataTableColumn<Order>(name: "AREA", type: .name, value: { $0.areaName }),
            KLDataTableColumn<Order>(name: "TABLE", type: .name, value: { $0.tableName }),
            KLDataTableColumn<Order>(name: "TIME", type: .time, value: { $0.createdTime.toString("HH:mm") }),
            KLDataTableColumn<Order>(name: "#GST.", type: .number, value: { "\($0.persons)" }),
            KLDataTableColumn<Order>(name: "QTY.", type: .number, value: { $0.quantity.asQuantity }),
            KLDataTableColumn<Order>(name: "TOTAL", type: .currency, value: { $0.total.asMoney }),
            KLDataTableColumn<Order>(name: "STAT.", type: .status, value: { $0.orderStatus.displayValue }) ])
    }
    
    override func on(assigned item: Order, to row: KLDataTableRow<Order>) {
        guard let lockIcon = row.cells.first as? UILabel,
            let stationID = SP.authService.station?.id
            else {
            return
        }
        lockIcon.textColor = theme.warn.base
        lockIcon.set(icon: FAKFontAwesome.lockIcon(withSize: 16))
        let lockedOrders = SP.dataService.lockedOrders.value
        
        let isLocked = lockedOrders.any { (key, value) -> Bool in
            key == item.id && stationID != value
        }
        lockIcon.alpha = isLocked ? 1 : 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel as? OrdersViewModel else { return }
        
        bar.leftViews = viewModel.statuses.value.map { st in
            let button = KLChip(theme: theme)
            button.title = st.displayValue
            viewModel.selectedStatuses
                .asObservable()
                .map { $0.contains(st) }
                .bind(to: button.rx.isSelected)
                .disposed(by: disposeBag)
            button.rx.tap
                .map { st }
                .bind(to: viewModel.selectStatus)
                .disposed(by: disposeBag)
            return button
        }
        // Reload based on lockedOrders changed
        SP.dataService.lockedOrders
            .asDriver()
            .filter { _ in !self.view.isHidden }
            .drive(onNext: { lockedOrders in
                self.table.table.reloadData()
            })
            .disposed(by: disposeBag)
        // Reload based on remote order changed
        SP.dataService.remoteOrderChanged
            .asDriver(onErrorJustReturn: [])
            .filter { _ in !self.view.isHidden }
            .map { _ -> () in }
            .drive(viewModel.reload)
            .disposed(by: disposeBag)
        // Reload everytime it got shown
        rx.viewWillDisappear
            .mapToVoid()
            .asDriver(onErrorJustReturn: ())
            .drive(viewModel.reload)
            .disposed(by: disposeBag)
    }
}

fileprivate extension OrderStatus {
    /// For displaying on Orders list.
    var displayValue: String {
        switch self {
        case .new: return "NEW"
        case .submitted: return "OPEN"
        case .printed: return "CHKD"
        case .checked: return "PAID"
        case .voided: return "VOID"
        }
    }
}
