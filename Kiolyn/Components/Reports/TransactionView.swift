//
//  TransactionView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FontAwesomeKit

/// For displaying transaction detail
class TransactionView: KLView {
    let theme = Theme.mainTheme
    var disposeBag: DisposeBag?
    
    let orderInfoView = KLView()
    let orderInfo = OrderInfo()
    let orderItems = OrderItemsList()
    let orderSummary = OrderItemsSummary()
    let actions = UIStackView()
    let printCheck = KLPrimaryFlatButton()
    let printReceipt = KLPrimaryFlatButton()
    
    var transDetail: (Order, Bill, Transaction)? {
        didSet {
            disposeBag = DisposeBag()
            
            guard let (order, bill, trans) = self.transDetail else {
                return
            }
            orderInfo.order = order
            orderSummary.orderItemsContainer = bill
            
            Driver
                .just(bill.items)
                .drive(orderItems.rx.items) { (tableView, row, item) in
                    let cell = tableView.dequeueReusableCell(withIdentifier: "billItem") as! BillItemTableViewCell
                    cell.orderItem = item
                    return cell
                }
                .disposed(by: disposeBag!)
            
            printCheck.rx.tap  
                .flatMap { dmodal { PrintBillDVM(transaction: trans, type: .check) } }
                .subscribe()
                .disposed(by: disposeBag!)
            printReceipt.rx.tap
                .flatMap { dmodal { PrintBillDVM(transaction: trans, type: .receipt) } }
                .subscribe()
                .disposed(by: disposeBag!)
        }
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = theme.cardBackgroundColor
        roundCorners(corners: .allCorners, radius: 2)
        clipsToBounds = true
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Transaction Order Info
        orderInfoView.addSubview(orderInfo)
        orderInfo.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline/2)
        }
        orderInfoView.backgroundColor = .clear
        orderInfoView.snp.makeConstraints { make in
            make.height.equalTo(theme.normalButtonHeight)
        }
        stack.addArrangedSubview(orderInfoView)
        stack.addArrangedSubview(KLLine())
        
        // Transaction Bill Items
        orderItems.register(BillItemTableViewCell.self, forCellReuseIdentifier: "billItem")
        stack.addArrangedSubview(orderItems)
        stack.addArrangedSubview(KLLine())

        // Transaction Bill Summary
        stack.addArrangedSubview(orderSummary)
        stack.addArrangedSubview(KLLine())

        // Transaction Actions
        stack.addArrangedSubview(actions)
        actions.axis = .horizontal
        actions.distribution = .fillEqually
        printCheck.titleColor = theme.secondary.base
        printCheck.set(icon: FAKFontAwesome.printIcon(withSize: 16), withText: "CHECK")
        actions.addArrangedSubview(printCheck)
        printReceipt.titleColor = theme.secondary.base
        printReceipt.set(icon: FAKFontAwesome.printIcon(withSize: 16), withText: "RECEIPT")
        actions.addArrangedSubview(printReceipt)
    }
}

