//
//  OrderActionsView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For displaying the bottom actions buttons.
class OrderActions: KLView {
    private let theme = Theme.mainTheme
    private let disposeBag = DisposeBag()
    private var viewModel: OrderDetailViewModel!
    
    private let rows = UIStackView()
    private let row1 = UIStackView()
    private let row2 = UIStackView()
    private let closeClear = UIView()
    
    private let clear = KLWarnRaisedButton()
    private let close = KLWarnRaisedButton()
    private let delete = KLWarnRaisedButton()
    private let send = KLPrimaryRaisedButton()
    private let check = KLPrimaryRaisedButton()
    private let togo = KLPrimaryRaisedButton()
    private let hold = KLPrimaryRaisedButton()
    private let sendWithoutPrint = KLPrimaryRaisedButton()
    private let showBills = KLPrimaryRaisedButton()
    
    private let sep = KLLine()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ viewModel: OrderDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        clear.title = "CLEAR"
        closeClear.addSubview(clear)
        clear.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        close.title = "CLOSE"
        closeClear.addSubview(close)
        close.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rows.axis = .vertical;
        rows.distribution = .fillEqually
        rows.alignment = .fill
        rows.spacing = theme.guideline/2
        addSubview(rows)
        rows.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline/2)
        }
        
        row1.axis = .horizontal;
        row1.distribution = .fillEqually
        row1.alignment = .fill
        row1.spacing = theme.guideline/2
        
        row1.addArrangedSubview(closeClear)
        delete.title = "DELETE"
        row1.addArrangedSubview(delete)
        send.title = "SEND"
        row1.addArrangedSubview(send)
        check.title = "CHECK"
        row1.addArrangedSubview(check)
        rows.addArrangedSubview(row1)
        row1.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
        }
        
        row2.axis = .horizontal;
        row2.distribution = .fillEqually
        row2.alignment = .fill
        row2.spacing = theme.guideline/2
        togo.title = "TOGO"
        row2.addArrangedSubview(togo)
        hold.title = "HOLD"
        row2.addArrangedSubview(hold)
        sendWithoutPrint.title = "SAVE"
        row2.addArrangedSubview(sendWithoutPrint)
        showBills.title = "BILLS"
        row2.addArrangedSubview(showBills)
        rows.addArrangedSubview(row2)
        row2.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
        }
        
        addSubview(sep)
        sep.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
        }
        
        close.rx.tap.bind(to: viewModel.close).disposed(by: disposeBag)
        clear.rx.tap.bind(to: viewModel.clear).disposed(by: disposeBag)
        delete.rx.tap.bind(to: viewModel.delete).disposed(by: disposeBag)
        send.rx.tap.map { .sent }.bind(to: viewModel.applyFilter).disposed(by: disposeBag)
        send.rx.tap.bind(to: viewModel.send).disposed(by: disposeBag)
        check.rx.tap.bind(to: viewModel.check).disposed(by: disposeBag)
        togo.rx.tap.bind(to: viewModel.togo).disposed(by: disposeBag)
        hold.rx.tap.bind(to: viewModel.hold).disposed(by: disposeBag)
        sendWithoutPrint.rx.tap.bind(to: viewModel.sendWithoutPrint).disposed(by: disposeBag)
        showBills.rx.tap.bind(to: viewModel.showBills).disposed(by: disposeBag)
        
        Driver.combineLatest(
            viewModel.orderManager.order.asDriver(),
            viewModel.selectedOrderItems.asDriver()) { ($0, $1) }
            .drive(onNext: { (order, selectedItems) in
                guard let order = order else {
                    self.close.isEnabled = false
                    self.clear.isEnabled = false
                    self.delete.isEnabled = false
                    self.send.isEnabled = false
                    self.check.isEnabled = false
                    self.togo.isEnabled = false
                    self.hold.isEnabled = false
                    self.sendWithoutPrint.isEnabled = false
                    self.showBills.isEnabled = false
                    return
                }
                let hasSubmittableItems = order.hasSubmittableItems
                let hasUnbilledItems = order.hasUnbilledItems
                let hasSelectedNewItems = order.items.any { item in
                    selectedItems.contains(item.id) && item.isNew
                }
                let hasSelectedSubmittedItems = order.items.any { item in
                    selectedItems.contains(item.id) && item.isSubmitted
                }
                
                self.close.isEnabled = order.isNotClosed && (order.isEmpty || order.allPaid)
                self.close.isHidden = !self.close.isEnabled
                self.clear.isEnabled = order.hasNewItems
                self.delete.isEnabled = order.items.any { item in
                    selectedItems.contains(item.id) &&
                        (item.isSubmitted || item.isChecked || item.isNew)
                }
                self.send.isEnabled = hasSubmittableItems || hasSelectedSubmittedItems || order.hasBills
                self.send.title = (hasSelectedSubmittedItems || order.hasBills) ? "RESEND" : "SEND"
                self.sendWithoutPrint.isEnabled = hasSubmittableItems
                self.togo.isEnabled = hasSelectedNewItems
                self.hold.isEnabled = hasSelectedNewItems
                self.showBills.isEnabled = order.hasBills && (order.isClosed || !hasUnbilledItems)
                self.check.isEnabled = hasUnbilledItems
            })
            .disposed(by: disposeBag)
    }
}
