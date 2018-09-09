//
//  BillView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// Single bill view.
class BillView: KLView {
    private let theme = Theme.mainTheme
    
    var disposeBag: DisposeBag?
    
    let bar = KLBar()
    let title = UILabel()
    let remove = KLBarFlatButton()
    let split = KLBarFlatButton()
    
    let billSummary = OrderItemsSummary()
    let paidSummary = BillPaidSummaryView()
    let actions = BillActionsView()
    let orderItems = OrderItemsList()
    
    let wrapper = UIStackView()
    let selectBill = KLFlatButton()
    
    /// The bill view model.
    var billViewModel: BillViewModel? {
        didSet {
            // Disconnect old bindings Rebinding actions
            disposeBag = DisposeBag()
            
            // Pass to sub view
            actions.billViewModel = billViewModel
            paidSummary.billViewModel = billViewModel
            billSummary.orderItemsContainer = billViewModel?.bill
            
            defer {
                layoutIfNeeded()
            }
            
            // Make sure we got something
            guard let viewModel = billViewModel else { return }
            
            let bill = viewModel.bill
            let order = viewModel.order
            
            Driver
                .just(viewModel.bill.items)
                .drive(orderItems.rx.items) { (tableView, row, item) in
                    let cell = tableView.dequeueReusableCell(withIdentifier: "billItem") as! BillItemTableViewCell
                    cell.orderItem = item
                    return cell
                }
                .disposed(by: disposeBag!)
            orderItems.rx.modelSelected(OrderItem.self)
                .filter { _ in bill.isNotPaid }
                .bind(to: viewModel.selectBillItem)
                .disposed(by: disposeBag!)
            
            // Update button status based on the moving bill
            viewModel.billList.movingBill
                .asDriver()
                .drive(onNext: { movingBill in
                    if let movingBill = movingBill {
                        // Moving mode, everything got disabled
                        self.remove.isEnabled = false
                        self.split.isEnabled = false
                        self.selectBill.isHidden = bill.paid || bill.isSplitted ||  movingBill.id == bill.id
                    } else {
                        self.remove.isEnabled =
                            // Bill is not already paid
                            bill.isNotPaid &&
                            // Bill is either not a splitted
                            (bill.isNotSplitted ||
                                // ... or there is another unpaid bill of the same group for merging back
                                order.bills.contains {
                                    $0.isNotPaid && $0.parentBill == bill.parentBill && $0.id != bill.id
                                }
                        )
                        self.split.isEnabled =
                            // Not exceed maximum number of bills
                            order.bills.count < 99 &&
                            // Bill is not yet paid and not empty
                            bill.isNotPaid && bill.items.count > 0 &&
                            // At least 1 item is needed to use this feature
                            bill.quantity > 0
                        self.selectBill.isHidden = true
                    }
                })
                .disposed(by: disposeBag!)
            
            remove.rx.tap
                .bind(to: viewModel.remove)
                .disposed(by: disposeBag!)
            split.rx.tap
                .bind(to: viewModel.split)
                .disposed(by: disposeBag!)
            selectBill.rx.tap
                .bind(to: viewModel.moveSelectedItemsToThisBill)
                .disposed(by: disposeBag!)
        }
    }
    
    /// The index of this bill.
    var billIndex: Int? {
        didSet {
            guard let billIndex = billIndex else { return }
            title.text = "Bill \(billIndex)"
        }
    }
    
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        layer.borderWidth = 1
        borderColor = theme.primary.darken4
        // BAR
        title.textColor = theme.secondary.base
        title.font = theme.heading1Font
        remove.fakIcon = FAKFontAwesome.timesIcon(withSize: 18)
        split.fakIcon = FAKFontAwesome.scissorsIcon(withSize: 18)
        bar.backgroundColor = .clear
        bar.leftViews = [title]
        bar.rightViews = [split, remove]
        bar.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(bar)
        
        // ITEMS
        orderItems.register(BillItemTableViewCell.self, forCellReuseIdentifier: "billItem")
        orderItems.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        wrapper.addArrangedSubview(orderItems)
        
        // SUMMARY
        let sep = KLLine()
        billSummary.addSubview(sep)
        sep.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
        }
        billSummary.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(billSummary)
        
        // PAID SUMMARY
        paidSummary.isHidden = true
        paidSummary.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(paidSummary)
        
        // ACTIONS
        actions.backgroundColor = .clear
        actions.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(actions)
        
        // CONTENT
        wrapper.axis = .vertical
        wrapper.spacing = 0
        wrapper.distribution = .fill
        wrapper.alignment = .fill
        addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // SELECT BILL
        selectBill.isHidden = true
        addSubview(selectBill)
        selectBill.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
