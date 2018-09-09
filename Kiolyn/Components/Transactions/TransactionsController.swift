//
//  OrderingController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// We just don't have space for this
class SmallNumpad: Numpad {
    override var keySize: Int { return 44 }
    override var keyMargin: Int { return 2 }
}

/// For displaying transactions.
class TransactionsController: CommonDataTableController<Transaction> {
    
    fileprivate let edit = KLBarPrimaryRaisedButton()
    fileprivate let printReceipt = KLBarPrimaryRaisedButton()
    fileprivate let printCheck = KLBarPrimaryRaisedButton()
    fileprivate let void = KLBarWarnRaisedButton()
    fileprivate let closeBatch = KLBarWarnRaisedButton()
    
    fileprivate let paymentTypeFilter = KLComboBox<String>()
    fileprivate let keyboard = KLToggleButton()
    
    fileprivate let numpad = SmallNumpad()
    
    fileprivate var currentTipField: (Transaction, AdjustTipField)? = nil
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: TransactionsViewModel = TransactionsViewModel()) {
        super.init(viewModel)
        columns.accept([
            KLDataTableColumn<Transaction>(name: "TRANS#", type: .largeNumber, value: { "\($0.transNum)" }),
            KLDataTableColumn<Transaction>(name: "TRANS TYPE", type: .transType, value: { $0.displayTransType }),
            KLDataTableColumn<Transaction>(name: "CARD TYPE", type: .cardType, value: { $0.displayCardType }),
            KLDataTableColumn<Transaction>(name: "CARD#", type: .cardNumber, value: { $0.cardNum }),
            KLDataTableColumn<Transaction>(name: "DEVICE", type: .name, value: { $0.paymentDeviceName }),
            KLDataTableColumn<Transaction>(name: "REF#", type: .largeNumber, value: { $0.refNum }),
            KLDataTableColumn<Transaction>(name: "TIP AMT.", type: .tip, value: { _ in "" }, format: self.format),
            KLDataTableColumn<Transaction>(name: "SALES AMT.", type: .currency, value: { $0.approvedAmountByStatus.asMoney }),
            KLDataTableColumn<Transaction>(name: "TOTAL AMT.", type: .currency, value: { $0.totalWithTipAmount.asMoney }) ])
    }
    
    override func layoutRootView() {
        rootView.axis = .horizontal
        rootView.distribution = .fill
        rootView.alignment = .center
        rootView.spacing = theme.guideline
        
        let contentBackgroundView = UIView()
        contentBackgroundView.backgroundColor = theme.cardBackgroundColor
        rootView.addArrangedSubview(contentBackgroundView)
        contentBackgroundView.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
        
        contentBackgroundView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        numpad.isHidden = true
        numpad.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rootView.addArrangedSubview(numpad)
        numpad.snp.makeConstraints { make in
            make.width.equalTo(self.numpad.expectedWidth)
            make.height.equalTo(self.numpad.expectedHeight)
        }
    }
    
    private func format(_ trans: Transaction, _ cell: UIView, _ disposeBag: DisposeBag) {
        guard let tip = cell as? AdjustTipField else {
            return
        }
        // Init first value
        tip.value = trans.tipAmount
        tip.loading.isHidden = true
        tip.status.isHidden = true
        if trans.canAdjust {
            tip.dividerColor = .white
            tip.isEnabled = true
            tip.alpha = 1.0
            tip.font = theme.normalFont
            tip.detailVerticalOffset = 6
            guard let returnButton = self.numpad.returnButton else {
                return
            }
            tip.rx.controlEvent(.didBecomeFirstResponder)
                .subscribe(onNext: { _ in
                    self.numpad.isHidden = false
                    self.keyboard.isSelected = true
                    self.currentTipField = (trans, tip)
                    self.numpad.returnButton?.isEnabled = tip.value != trans.tipAmount
                })
                .disposed(by: disposeBag)
            tip.rx.controlEvent(.didResignFirstResponder)
                .subscribe(onNext: { _ in self.adjust(tip: tip, for: trans) })
                .disposed(by: disposeBag)
            tip.rx.doubleValue
                .asDriver()
                .map { tip in tip != trans.tipAmount }
                .drive(returnButton.rx.isEnabled)
                .disposed(by: disposeBag)
            tip.rx.doubleValue
                .asDriver()
                .drive(onNext: { tip in
                    guard let totalLabel = cell.superview?.subviews.last as? UILabel else { return }
                    totalLabel.text = (tip + trans.approvedAmountByStatus).asMoney
                })
                .disposed(by: disposeBag)
        } else {
            tip.dividerColor = .clear
            tip.isEnabled = false
            tip.alpha = 1.0
            tip.font = theme.xsmallFont
            tip.detailVerticalOffset = 4
        }
        numpad.textFields.append(tip)
    }
    
    override func on(assigned item: Transaction, to row: KLDataTableRow<Transaction>) {
        row.cellTextColor = item.isVoided ? theme.warn.base : theme.textColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edit.fakIcon = FAKFontAwesome.editIcon(withSize: 16)
        printCheck.set(icon: FAKFontAwesome.printIcon(withSize: 16), withText: "CHECK")
        printReceipt.set(icon: FAKFontAwesome.printIcon(withSize: 16), withText: "RECEIPT")
        void.title = "VOID"

        keyboard.fakIcon = FAKFontAwesome.keyboardOIcon(withSize: 16)
        keyboard.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        closeBatch.titleLabel?.numberOfLines = 2
        closeBatch.titleLabel?.textAlignment = .center
        let closeBatchTitle = NSMutableAttributedString(string: "CLOSE\n", attributes: [
            NSAttributedStringKey.font: theme.smallFont,
            NSAttributedStringKey.foregroundColor: theme.textColor])
        closeBatchTitle.append(NSAttributedString(string: "BATCH", attributes: [
            NSAttributedStringKey.font: theme.xsmallFont,
            NSAttributedStringKey.foregroundColor: theme.textColor]))
        closeBatch.setAttributedTitle(closeBatchTitle, for: .normal)
        closeBatch.contentEdgeInsetsPreset = .wideRectangle1

        bar.leftViews = [paymentTypeFilter, keyboard]
        bar.leftContainerView.alignment = .center
        
        bar.rightViews = [refresh, edit, printCheck, printReceipt, void, closeBatch]
        
        keyboard.rx.tap
            .map { _ in !self.numpad.isHidden }
            .bind(to: numpad.rx.isHidden)
            .disposed(by: disposeBag)
        
        guard let viewModel = viewModel as? TransactionsViewModel else {
            return
        }
        
        viewModel.paymentTypes
            .asObservable()
            .bind(to: paymentTypeFilter.items)
            .disposed(by: disposeBag)
        paymentTypeFilter.selectedItem
            .asObservable()
            .skip(1)
            .map { $0?.1 }
            .filterNil()
            .bind(to: viewModel.selectedPaymentType)
            .disposed(by: disposeBag)

        viewModel.selectedRow
            .asDriver()
            .drive(onNext: { trans in
                guard let trans = trans else {
                    self.edit.isEnabled = false
                    self.void.isEnabled = false
                    self.printReceipt.isEnabled = false
                    self.printCheck.isEnabled = false
                    return
                }
                self.edit.isEnabled = trans.transStatus == .new && trans.transType.hasCheck
                self.printReceipt.isEnabled = true
                self.printCheck.isEnabled = trans.transType.hasCheck
                self.void.isEnabled = trans.canVoid
            })
            .disposed(by: disposeBag)

        viewModel.data
            .asDriver()
            .map { $0.rows.isNotEmpty }
            .drive(closeBatch.rx.isEnabled)
            .disposed(by: disposeBag)
        
        closeBatch.rx.tap.asDriver().drive(viewModel.closeBatch).disposed(by: disposeBag)
        edit.rx.tap.asDriver().drive(viewModel.edit).disposed(by: disposeBag)
        printCheck.rx.tap.asDriver().drive(viewModel.printCheck).disposed(by: disposeBag)
        printReceipt.rx.tap.asDriver().drive(viewModel.printReceipt).disposed(by: disposeBag)
        void.rx.tap.asDriver().drive(viewModel.void).disposed(by: disposeBag)

        numpad.returnButton?.rx.tap
            .subscribe(onNext: { _ in
                guard let (trans, tipField) = self.currentTipField else {
                    return
                }
                self.adjust(tip: tipField, for: trans)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .reload
            .subscribe(onNext: { _ in self.numpad.textFields.removeAll() })
            .disposed(by: disposeBag)
    }
    
    private func adjust(tip field: AdjustTipField, for transaction: Transaction) {
        guard !field.adjusting, let vm = self.viewModel as? TransactionsViewModel else {
            return
        }
        // It's a one time thing
        _ = vm.adjust(tip: Double(field.value), for: transaction)
            .asDriver(onErrorJustReturn: ViewStatus.error(reason: "Unknown"))
            .drive(field.rx.status)
    }
}
