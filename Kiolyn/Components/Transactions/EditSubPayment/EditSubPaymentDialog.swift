//
//  EditSubPaymentDialog.swift
//  Kiolyn
//
//  Created by TienPham on 10/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// Open sub payment items dialog and return the sub payment type.
class EditSubPaymentDialog: KLDialog<Transaction> {
    
    private var viewModel: EditSubPaymentDVM
    
    private let content = UIView()
    private let subPaymentTypes = UIStackView()
    private let nonePayment = FlatButton()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Transaction>) {
        guard let vm = vm as? EditSubPaymentDVM else {
            fatalError("Expecting PrintItemsDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override func makeDialogContentView() -> UIView? {
        let view = UIView()
        
        view.addSubview(content)
        
        subPaymentTypes.axis = .horizontal
        subPaymentTypes.alignment = .trailing
        subPaymentTypes.distribution = .fill
        subPaymentTypes.spacing = theme.guideline
        content.addSubview(subPaymentTypes)
        
        return view
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline)
        }

        subPaymentTypes.snp.makeConstraints { make in
            make.top.leading.width.equalToSuperview()
            make.leading.width.equalToSuperview()
            make.height.equalTo(self.theme.normalButtonHeight)
        }
        
    }
    
    override func makeDialogBottomBar() -> Bar? {
        let bar = Bar()
        nonePayment.titleLabel?.font = theme.normalFont
        nonePayment.title = "NONE"
        nonePayment.titleColor = theme.warn.base
        bar.rightViews = [nonePayment]
        nonePayment.rx.tap
            .map { EmptySubPaymentType() }
            .bind(to: viewModel.selectSubPaymentType)
            .disposed(by: disposeBag)
        return bar
    }
    
    override func prepare() {
        super.prepare()
        
        viewModel.subPaymentTypes
            .drive(onNext: { types -> Void in
                self.build(with: types)
                self.update()
            })
            .disposed(by: disposeBag)
        
        viewModel.subPaymentType
            .asDriver()
            .drive(onNext: { _ in self.update() })
            .disposed(by: disposeBag)
        
    }
    
    func build(with types: [PaymentType]) {
        for v in subPaymentTypes.arrangedSubviews {
            v.removeFromSuperview()
        }
        for t in types {
            let ptButton = PaymentTypeButton(theme)
            ptButton.paymentType = t
            subPaymentTypes.addArrangedSubview(ptButton)
            ptButton.rx.tap
                .map { t }
                .bind(to: viewModel.selectSubPaymentType)
                .disposed(by: ptButton.disposeBag)
        }
        subPaymentTypes.addArrangedSubview(UIView())
    }
    
    func update() {
        for v in subPaymentTypes.arrangedSubviews {
            guard let ptButton = v as? PaymentTypeButton else {
                continue
            }
            ptButton.isSelected = viewModel.subPaymentType.value == ptButton.paymentType
        }
    }
}

