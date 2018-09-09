//
//  TablesLayoutViewController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import CoreGraphics
import RxSwift
import RxCocoa
import Material
import SnapKit
import FontAwesomeKit

typealias TablesState = (AreaViewModel?, (MovingModeType, Order)?, TableViewModel?, [String: String])

/// Root view controller for the whole tables layout view.
class TablesLayoutController: UIViewController {
    let theme =  Theme.mainTheme
    let disposeBag = DisposeBag()

    let viewModel = TablesLayoutViewModel()

    // Areas view
    let areasView = KLTableView()
    // Tables view
    let tablesView = TablesView(true)
    // Message views
    let messageView = Material.Snackbar()
    let cancelMovingModeButton = KLFlatButton()
    let moveHereButton = KLPrimaryRaisedButton()
    // The actions area
    let actionsView = UIStackView()
    let openButton = KLPrimaryRaisedButton()
    let printCheckButton = KLPrimaryRaisedButton()
    let payButton = KLPrimaryRaisedButton()
    let payByCardButton = KLPrimaryRaisedButton()
    let moveToButton = KLPrimaryRaisedButton()
    let combineWithButton = KLPrimaryRaisedButton()
    let addOrderButton = KLPrimaryRaisedButton()
    let refreshButton = KLPrimaryRaisedButton()
    // The filtering view
    let filterView = KLTableView()

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = theme.backgroundColor

        // AREAS
        areasView.rowHeight = theme.mediumButtonHeight
        areasView.register(SelectableTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(areasView)
        areasView.snp.makeConstraints { make in
            make.width.equalTo(160)
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(theme.guideline/2)
            make.bottom.equalToSuperview().offset(-theme.guideline/2)
        }
        viewModel.areas
            .asDriver()
            .drive(areasView.rx.items) { (tableView, row, areaVM) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SelectableTableViewCell
                cell.disposeBag = DisposeBag()
                areaVM.areaDetail
                    .drive(cell.textLabel!.rx.text)
                    .disposed(by: cell.disposeBag!)
                areaVM.orders
                    .asDriver()
                    .map { orders in orders.isEmpty ? self.theme.textColor : self.theme.warn.base }
                    .drive(cell.rx.textColor)
                    .disposed(by: cell.disposeBag!)
                self.viewModel.selectedArea
                    .asDriver()
                    .map { selectedArea in selectedArea?.area.id == areaVM.area.id }
                    .drive(cell.rx.isSelected)
                    .disposed(by: cell.disposeBag!)
                return cell
            }
            .disposed(by: disposeBag)
        areasView.rx.modelSelected(AreaViewModel.self)
            .bind(to: viewModel.selectedArea)
            .disposed(by: disposeBag)

        // MARK: - Actions
        actionsView.axis = .vertical;
        actionsView.distribution = .fill
        actionsView.alignment = .fill
        actionsView.spacing = theme.guideline
        view.addSubview(actionsView)
        actionsView.snp.makeConstraints { make in
            make.width.equalTo(132)
            make.top.equalToSuperview().offset(theme.guideline/2)
            make.trailing.equalToSuperview().offset(-theme.guideline/2)
        }

        openButton.title = "OPEN"
        printCheckButton.title = "PRINT CHECK"
        payButton.title = "PAY"
        payByCardButton.title = "PAY BY CREDIT"
        moveToButton.title = "MOVE TO"
        combineWithButton.title = "COMBINE WITH"
        addOrderButton.set(icon: FAKFontAwesome.plusIcon(withSize: theme.normalFontSize), withText: "NEW ORDER")
        refreshButton.set(icon: FAKFontAwesome.refreshIcon(withSize: theme.normalFontSize), withText: "REFRESH")
        for button in [openButton, printCheckButton, payButton, payByCardButton, moveToButton, combineWithButton, addOrderButton, refreshButton] {
            actionsView.addArrangedSubview(button)
            button.snp.makeConstraints{ make in
                make.height.equalTo(self.theme.mediumButtonHeight)
            }
        }
        actionsView.addArrangedSubview(UIView()) // Padding view
        // Common action input to enable action which is
        // 1. Not in moving mode => all action are disabled when in moving mode
        // 2. Have a selected table to perform action on
        // 3. Locked Orders changed remotely
        Driver.combineLatest(
            viewModel.selectedArea.asDriver(),
            viewModel.selectedOrder.asDriver(),
            viewModel.selectedTable.asDriver(),
            viewModel.dataService.lockedOrders.asDriver())
            .drive(onNext: { state in self.update(state: state) })
            .disposed(by: disposeBag)
        
        openButton.rx.tap.bind(to: viewModel.open).disposed(by: disposeBag)
        printCheckButton.rx.tap.bind(to: viewModel.printCheck).disposed(by: disposeBag)
        payButton.rx.tap.bind(to: viewModel.pay).disposed(by: disposeBag)
        payByCardButton.rx.tap.bind(to: viewModel.payByCard).disposed(by: disposeBag)
        moveToButton.rx.tap.bind(to: viewModel.move).disposed(by: disposeBag)
        combineWithButton.rx.tap.bind(to: viewModel.combine).disposed(by: disposeBag)
        addOrderButton.rx.tap.bind(to: viewModel.addOrder).disposed(by: disposeBag)
        refreshButton.rx.tap.bind(to: viewModel.reloadOrders).disposed(by: disposeBag)
        refreshButton.rx.tap
            .subscribe(onNext: { _ -> Void in
                SP.restClient.restartEventClientIfStopped()
            })
            .disposed(by: disposeBag)

        // MARK: - Message
        messageView.isHidden = true
        messageView.textLabel.font = theme.normalFont
        messageView.backgroundColor = theme.warn.base
        cancelMovingModeButton.title = "CANCEL"
        cancelMovingModeButton.titleLabel?.font = theme.normalFont
        cancelMovingModeButton.titleColor = theme.secondary.base
        messageView.rightViews = [cancelMovingModeButton]
        view.addSubview(messageView)
        messageView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.bottom.equalToSuperview()
            make.leading.equalTo(areasView.snp.trailing)
            make.trailing.equalTo(actionsView.snp.leading).offset(-theme.guideline/2)
        }
        cancelMovingModeButton.rx.tap
            .map { _ -> (MovingModeType, Order)? in nil }
            .bind(to: viewModel.selectedOrder)
            .disposed(by: disposeBag)
        viewModel.selectedOrder
            .asDriver()
            .skip(1)
            .drive(onNext: { self.showHide(message: $0) })
            .disposed(by: disposeBag)
        
        // MARK: - Tables/Orders List
        view.addSubview(tablesView)
        tablesView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(theme.guideline/2)
            make.bottom.equalTo(messageView.snp.top).offset(-theme.guideline/2)
            make.leading.equalTo(areasView.snp.trailing)
            make.trailing.equalTo(actionsView.snp.leading).offset(-theme.guideline/2)
        }
        viewModel.selectedArea
            .asDriver()
            .drive(tablesView.area)
            .disposed(by: disposeBag)
        tablesView.selectTable
            .subscribe(onNext: { table in
                let vm = self.viewModel
                // Not in a moving mode, thus set the selected table
                guard let (mode, order) = vm.selectedOrder.value else {
                    vm.selectedTable.accept(table)
                    return
                }
                // In moving mode, call the corresponding stream
                // based on the current selected mode
                if mode == .move {
                    vm.moveTo.onNext((order, table.area, table.table))
                } else {
                    vm.combineWith.onNext((order, table))
                }
            })
            .disposed(by: disposeBag)
        tablesView.selectCustomer.bind(to: viewModel.editCustomer).disposed(by: disposeBag)
        tablesView.selectDriver.bind(to: viewModel.editDriver).disposed(by: disposeBag)
        tablesView.selectDelivered.bind(to: viewModel.editDelivered).disposed(by: disposeBag)
        
        // MARK: Move Here button
        moveHereButton.isHidden = true
        moveHereButton.setTitle("MOVE HERE", for: .normal)
        view.addSubview(moveHereButton)
        moveHereButton.snp.makeConstraints { make in
            make.bottom.equalTo(tablesView.snp.bottom).offset(-theme.guideline)
            make.left.equalTo(tablesView.snp.left).offset(theme.guideline)
            make.right.equalTo(tablesView.snp.right).offset(-theme.guideline)
            make.height.equalTo(theme.largeButtonHeight)
        }
        moveHereButton.rx.tap
            .map { _ -> (Order, Area, Table?)? in
                guard let (mode, order) = self.viewModel.selectedOrder.value, mode == .move,
                    let area = self.viewModel.selectedArea.value else {
                    return nil
                }
                return (order, area.area, nil)
            }
            .filterNil()
            .bind(to: viewModel.moveTo)
            .disposed(by: disposeBag)
        
        // FILTERS
        filterView.rowHeight = theme.mediumButtonHeight
        filterView.register(SelectableTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(filterView)
        filterView.snp.makeConstraints { make in
            make.width.equalTo(132)
            make.bottom.equalToSuperview().offset(-theme.guideline/2)
            make.trailing.equalToSuperview().offset(-theme.guideline/2)
        }        
        viewModel.deliveredFilters
            .asDriver()
            .drive(filterView.rx.items) { (tableView, row, filter) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SelectableTableViewCell
                cell.disposeBag = DisposeBag()
                cell.textLabel?.text = filter.rawValue
                self.viewModel.selectedFilter
                    .asDriver()
                    .drive(onNext: { cell.isSelected = $0 == filter })
                    .disposed(by: cell.disposeBag!)
                return cell
            }
            .disposed(by: disposeBag)
        viewModel.selectedArea
            .asDriver()
            .filterNil()
            .map { $0.area.isNotDelivery }
            .drive(filterView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.deliveredFilters
            .asDriver()
            .map { CGFloat($0.count) * self.theme.mediumButtonHeight }
            .drive(onNext: { height in
                self.filterView.snp.makeConstraints { make in
                    make.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)
        filterView.rx.modelSelected(DeliveredFilter.self)
            .bind(to: viewModel.selectedFilter)
            .disposed(by: disposeBag)

        // Reload on appearing
        rx.viewDidAppear
            .mapToVoid()
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
    }
    
    private func showHide(message selectedOrder: (MovingModeType, Order)?) {
        // Show/hide SnackBar
        guard let (mode, order) = selectedOrder else {
            self.messageView.text = ""
            UIView.animate(withDuration: 0.2) {
                self.messageView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                self.view.layoutIfNeeded()
            }
            return
        }
        if mode == .move {
            self.messageView.text = "Please select the target Table to move Order #\(order.orderNo) to."
        } else {
            self.messageView.text = "Please select the target Table to combine with Order #\(order.orderNo)."
        }
        self.messageView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.messageView.snp.updateConstraints { make in
                make.height.equalTo(self.theme.normalButtonHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func update(state: TablesState) {
        let (selectedArea, selectedOrder, selectedTable, lockedOrders) = state
        // Disable all actions
        openButton.isEnabled = false
        printCheckButton.isEnabled = false
        payButton.isEnabled = false
        payByCardButton.isEnabled = false
        moveToButton.isEnabled = false
        combineWithButton.isEnabled = false
        addOrderButton.isEnabled = false
        moveHereButton.isHidden = true
        // Check for moving mode
        if let order = selectedOrder, let area = selectedArea?.area {
            // Moving mode, everything should be kept disabled
            // See if we should show the MoveHere button (moving mode + current area is auto increment)
            moveHereButton.isHidden = order.0 != .move || !area.isAutoIncrement || area.id == order.1.area
            return
        }
        // Not moving mode, we need to enable buttons based on other elements
        guard let table = selectedTable else {
            // There is NO selected table, only AddOrder might be enabled
            addOrderButton.isEnabled = selectedArea?.area.isAutoIncrement ?? false
            return
        }
        
        // Now we need to define status based on selected table's orders
        let orders = table.orders.value
        openButton.isEnabled = orders.isEmpty || orders.any { lockedOrders.isNotLocked($0) }
        let hasUnpaidBill = orders.any { order in
            lockedOrders.isNotLocked(order) && order.isNotNew && order.isNotClosed
        }
        printCheckButton.isEnabled = hasUnpaidBill
        payButton.isEnabled = hasUnpaidBill
        payByCardButton.isEnabled = hasUnpaidBill
        
        moveToButton.isEnabled = orders.any { order in !lockedOrders.isLocked(order) && order.isNotClosed }
        
        combineWithButton.isEnabled = orders.any { order in
            lockedOrders.isNotLocked(order) && order.isNotClosed && order.bills.isEmpty
        }
        
        addOrderButton.isEnabled = true
    }
}





