//
//  ForceDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

class ForceDialog: KLDialog<(Double, String)> {
    
    private var viewModel: ForceDVM
    
    private let amount = KLCashField()
    private let authCode = KLTextField()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<(Double, String)>) {
        guard let vm = vm as? ForceDVM else {
            fatalError("Expecting RefundDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [(amount, cashKeyboard), (authCode, textKeyboard)]
    }
    
    override func makeDialogContentView() -> UIView? {
        let content = UIView()
        
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.distribution = .fillProportionally
        wrapper.alignment = .fill
        wrapper.spacing = theme.guideline * 4
        content.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(theme.guideline * 2)
            make.right.equalToSuperview().offset(-theme.guideline * 2)
        }
        
        amount.value = 0
        amount.placeholder = "Force Amount"
        amount.font = theme.xxlargeInputFont
        amount.placeholderActiveScale = 0.45
        amount.placeholderVerticalOffset = 44.0
        amount.textColor = theme.textColor
        wrapper.addArrangedSubview(amount)
        amount.snp.makeConstraints { make in
            make.height.equalTo(theme.largeInputHeight)
        }
        
        authCode.placeholder = "Authentication Code"
        authCode.font = theme.xxlargeInputFont
        authCode.placeholderActiveScale = 0.45
        authCode.placeholderVerticalOffset = 44.0
        authCode.textColor = theme.textColor
        wrapper.addArrangedSubview(authCode)
        authCode.snp.makeConstraints { make in
            make.height.equalTo(theme.largeInputHeight)
        }

        return content
    }
    
    override func prepare() {
        super.prepare()
        
        amount.rx.doubleValue
            .asDriver()
            .drive(viewModel.amount)
            .disposed(by: disposeBag)
        
        authCode.rx.text
            .changed
            .asDriver()
            .filterNil()
            .drive(viewModel.authCode)
            .disposed(by: disposeBag)
        
        viewModel
            .dialogDidAppear
            .subscribe(onNext: { _ in
                _ = self.amount.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}
