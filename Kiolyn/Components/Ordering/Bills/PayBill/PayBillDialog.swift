//
//  PayBillDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// Open print items dialog and return the printed items.
class PayBillDialog: KLDialog<PayBillInfo> {
    
    private var viewModel: PayBillDVM
    
    private let content = UIView()
    private let paymentTypeLabel = UILabel()
    private let paymentTypes = UIScrollView(frame: CGRect.zero)
    private let subPaymentTypeLabel = UILabel()
    private let subPaymentTypes = UIStackView()
    
    private let amountDueLabel = UILabel()
    private let amountDue = UILabel()
    private let tipAmountLabel = UILabel()
    private let tipAmount = KLCashField()
    private let payingAmountLabel = UILabel()
    private let payingAmount = KLCashField()
    
    // Define the maximum payment types in horizontal
    private let maxHorizontalItems = 5
    
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [
            (payingAmount, cashKeyboard),
            (tipAmount, cashKeyboard)
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<PayBillInfo>) {
        guard let vm = vm as? PayBillDVM else {
            fatalError("Expecting PrintItemsDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override func makeDialogContentView() -> UIView? {
        let view = UIView()
        
        view.addSubview(content)
        
        paymentTypeLabel.text = "PAYMENT TYPE"
        paymentTypeLabel.font = theme.normalFont
        paymentTypeLabel.textColor = theme.primary.base
        content.addSubview(paymentTypeLabel)
        
        content.addSubview(paymentTypes)
        
        subPaymentTypeLabel.text = "SUB PAYMENT TYPE"
        subPaymentTypeLabel.font = theme.normalFont
        subPaymentTypeLabel.textColor = theme.primary.base
        content.addSubview(subPaymentTypeLabel)
        
        subPaymentTypes.axis = .horizontal
        subPaymentTypes.alignment = .trailing
        subPaymentTypes.distribution = .fill
        subPaymentTypes.spacing = theme.guideline
        content.addSubview(subPaymentTypes)
        
        amountDueLabel.text = "Amount Due"
        amountDueLabel.font = theme.heading1Font
        amountDueLabel.textAlignment = .right
        amountDueLabel.textColor = theme.secondaryTextColor
        content.addSubview(amountDueLabel)
        
        tipAmountLabel.text = "Tip Amount"
        tipAmountLabel.font = theme.heading1Font
        tipAmountLabel.textAlignment = .right
        tipAmountLabel.textColor = theme.secondaryTextColor
        content.addSubview(tipAmountLabel)
        
        payingAmountLabel.text = "Tender Amount"
        payingAmountLabel.font = theme.heading1Font
        payingAmountLabel.textAlignment = .right
        payingAmountLabel.textColor = theme.secondaryTextColor
        content.addSubview(payingAmountLabel)
        
        amountDue.text = 0.0.asMoney
        amountDue.font = theme.subTitleBoldFont
        amountDue.textAlignment = .right
        amountDue.textColor = theme.textColor
        content.addSubview(amountDue)
        
        payingAmount.text = 0.0.asMoney
        payingAmount.font = theme.xxxlargeInputFont
        payingAmount.textAlignment = .right
        payingAmount.placeholder = ""
        payingAmount.textColor = theme.primary.base
        payingAmount.dividerColor = theme.primary.base
        content.addSubview(payingAmount)
        
        tipAmount.text = 0.0.asMoney
        tipAmount.font = theme.xxxlargeInputFont
        tipAmount.textAlignment = .right
        tipAmount.placeholder = ""
        tipAmount.textColor = theme.primary.base
        tipAmount.dividerColor = theme.primary.base
        content.addSubview(tipAmount)
        
        return view
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline)
        }
        paymentTypeLabel.snp.makeConstraints { make in
            make.top.leading.width.equalToSuperview()
        }
        paymentTypes.snp.makeConstraints { make in
            make.top.equalTo(paymentTypeLabel.snp.bottom).offset(theme.guideline)
            make.leading.width.equalToSuperview()
            make.height.equalTo((self.theme.normalButtonHeight + theme.guideline) * 2)
        }
        subPaymentTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(paymentTypes.snp.bottom).offset(theme.guideline)
            make.leading.width.equalToSuperview()
        }
        subPaymentTypes.snp.makeConstraints { make in
            make.top.equalTo(subPaymentTypeLabel.snp.bottom).offset(theme.guideline)
            make.leading.width.equalToSuperview()
            make.height.equalTo(self.theme.normalButtonHeight)
        }
        payingAmountLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.55)
            make.height.equalTo(theme.xlargeInputHeight)
        }
        payingAmount.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(theme.xlargeInputHeight)
        }
        tipAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(payingAmountLabel.snp.leading)
            make.trailing.equalTo(payingAmountLabel.snp.trailing)
            make.bottom.equalTo(payingAmountLabel.snp.top).offset(-theme.guideline)
            make.height.equalTo(payingAmountLabel.snp.height)
        }
        tipAmount.snp.makeConstraints { make in
            make.leading.equalTo(payingAmount.snp.leading)
            make.trailing.equalTo(payingAmount.snp.trailing)
            make.bottom.equalTo(payingAmount.snp.top).offset(-theme.guideline)
            make.height.equalTo(payingAmount.snp.height)
        }
        amountDueLabel.snp.makeConstraints { make in
            make.leading.equalTo(tipAmountLabel.snp.leading)
            make.trailing.equalTo(tipAmountLabel.snp.trailing)
            make.bottom.equalTo(tipAmountLabel.snp.top).offset(-theme.guideline)
            make.height.equalTo(tipAmountLabel.snp.height)
        }
        amountDue.snp.makeConstraints { make in
            make.leading.equalTo(tipAmount.snp.leading)
            make.trailing.equalTo(tipAmount.snp.trailing)
            make.bottom.equalTo(tipAmount.snp.top).offset(-theme.guideline)
            make.height.equalTo(tipAmount.snp.height)
        }
    }
    
    override func prepare() {
        super.prepare()
        
        let billTotal = viewModel.bill.total
        
        amountDue.text = billTotal.asMoney
        amountDue.rx.tapGesture()
            .map { _ in (billTotal + self.viewModel.tipAmount.value) }
            .bind(to: payingAmount.rx.doubleValue)
            .disposed(by: disposeBag)
        payingAmount.rx.doubleValue
            .asDriver()
            .drive(onNext: { (amount: Double) in
                self.viewModel.payingAmount.accept(amount)
                self.payingAmount.text = amount.asMoney
                if amount > 0 {
                    self.payingAmount.textColor = self.theme.primary.base
                    self.payingAmount.dividerColor = self.theme.primary.base
                } else {
                    self.payingAmount.textColor = self.theme.warn.base
                    self.payingAmount.dividerColor = self.theme.warn.base
                }
            })
            .disposed(by: disposeBag)
        
        tipAmount.rx.doubleValue
            .asDriver()
            .drive(onNext: { (amount: Double) in
                self.viewModel.tipAmount.accept(amount)
                // update paying amount
                let type = self.viewModel.selectedPaymentType.value
                guard type is CashPaymentType else {
                    self.payingAmount.text = (billTotal + amount).asMoney
                    self.viewModel.payingAmount.accept(billTotal + amount)
                    return
                }
            })
            .disposed(by: disposeBag)

        build(viewModel.paymentTypes.value, tap: viewModel.selectedPaymentType)
        
        viewModel.selectedPaymentType
            .asDriver()
            .drive(onNext: { type in
                self.update(self.paymentTypes, selected: type)
                if let _ = type as? CashPaymentType {
                    self.payingAmount.value = 0
                    self.payingAmount.maxValue = 99999999
                    self.payingAmountLabel.text = "Tender Amount"
                } else {
                    self.payingAmount.value = billTotal + self.viewModel.tipAmount.value
                    self.payingAmount.maxValue = billTotal
                    self.payingAmountLabel.text = "Charge Amount"
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.subPaymentTypes
            .drive(onNext: { types -> Void in
                self.build(self.subPaymentTypes, with: types, tap: self.viewModel.selectedSubPaymentType)
                // Update selected when view is ready
                self.update(self.subPaymentTypes, selected: self.viewModel.selectedSubPaymentType.value)
            })
            .disposed(by: disposeBag)
    
        viewModel.selectedSubPaymentType
            .asDriver()
            .drive(onNext: { self.update(self.subPaymentTypes, selected: $0) })
            .disposed(by: disposeBag)
        
        viewModel.dialogDidAppear
            .subscribe(onNext: { _ = self.payingAmount.becomeFirstResponder() })
            .disposed(by: disposeBag)
    }
    
    func build(_ types: [PaymentType], tap to: BehaviorRelay<PaymentType>) {
        // remove all subview in all stackview
        for stackView in paymentTypes.subviews {
            if let stackView = stackView as? UIStackView {
                for v in stackView.arrangedSubviews {
                    v.removeFromSuperview()
                }
            }
            stackView.removeFromSuperview()
        }
        // calculate to create number of stackview + size of scroll view
        var rowTypes = [[]]
        var count = 1
        var row = 0
        let maxWidth = dialogWidth - 2 * theme.guideline
        var rowWidth: CGFloat = 0
        for t in types {
            let ptButton = PaymentTypeButton(theme)
            ptButton.paymentType = t
            rowWidth += ptButton.intrinsicContentSize.width + theme.guideline
            if rowWidth > maxWidth {
                row += 1
                count = 1
                rowWidth = ptButton.intrinsicContentSize.width + theme.guideline
                rowTypes.append([])
                rowTypes[row].append(ptButton)
            } else {
                rowTypes[row].append(ptButton)
            }
            ptButton.rx.tap
                .map { t }
                .bind(to: to)
                .disposed(by: ptButton.disposeBag)
            count += 1
        }
        
        // set scroll view height
        paymentTypes.snp.makeConstraints { make in
            make.top.equalTo(paymentTypeLabel.snp.bottom).offset(theme.guideline)
            make.leading.width.equalToSuperview()
            make.height.equalTo((self.theme.normalButtonHeight + theme.guideline) * CGFloat(row + 1))
        }
        paymentTypes.contentSize = CGSize(width: paymentTypes.contentSize.width, height: (self.theme.normalButtonHeight + theme.guideline) * CGFloat(row + 1))
        
        // draw to UI
        var prevStackView: UIStackView?
        for buttons in rowTypes {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .leading
            stackView.distribution = .fill
            stackView.spacing = theme.guideline
            paymentTypes.addSubview(stackView)
            
            if let prevStackView = prevStackView {
                stackView.snp.makeConstraints { make in
                    make.top.equalTo(prevStackView.snp.bottom).offset(theme.guideline)
                    make.leading.width.equalToSuperview()
                    make.height.equalTo(self.theme.normalButtonHeight)
                }
            } else {
                stackView.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(theme.guideline)
                    make.leading.width.equalToSuperview()
                    make.height.equalTo(self.theme.normalButtonHeight)
                }
            }
            
            // draw items
            for button in buttons {
                stackView.addArrangedSubview(button as! PaymentTypeButton)
            }
            
            // set prev stackview
            prevStackView = stackView
            stackView.addArrangedSubview(UIView())
        }
    }
    
    func build(_ view: UIStackView, with types: [PaymentType], tap to: BehaviorRelay<PaymentType>) {
        for v in view.arrangedSubviews {
            v.removeFromSuperview()
        }
        for t in types {
            let ptButton = PaymentTypeButton(theme)
            ptButton.paymentType = t
            view.addArrangedSubview(ptButton)
            
            ptButton.rx.tap
                .map { t }
                .bind(to: to)
                .disposed(by: ptButton.disposeBag)
        }
        view.addArrangedSubview(UIView())
    }
    
    func update(_ view: UIView, selected type: PaymentType?) {
        
        if let view: UIStackView = view as? UIStackView {
            for v in view.arrangedSubviews {
                guard let ptButton = v as? PaymentTypeButton else { continue }
                ptButton.isSelected = type == ptButton.paymentType
            }
        } else {
            for stackView in paymentTypes.subviews {
                if let stackView = stackView as? UIStackView {
                    for v in stackView.arrangedSubviews {
                        guard let ptButton = v as? PaymentTypeButton else { continue }
                        ptButton.isSelected = type == ptButton.paymentType
                    }
                }
            }
        }
    }
}

/// For selecting payment type/sub payment type in Payment Dialog.
class PaymentTypeButton: KLRaisedButton {
    let disposeBag = DisposeBag()
    
    var paymentType: PaymentType? {
        didSet {
            guard let paymentType = paymentType else { return }
            title = paymentType.name.uppercased()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: theme.normalButtonHeight)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = theme.primary.base
                titleColor = .white
            } else {
                backgroundColor = .white
                titleColor = theme.primary.base
            }
        }
    }
    
    override func prepare() {
        super.prepare()
        isSelected = false
        borderColor = theme.primary.lighten1
        layer.borderWidth = 1.0
        titleLabel?.font = theme.smallFont
    }
}


