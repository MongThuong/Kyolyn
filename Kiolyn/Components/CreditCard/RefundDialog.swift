//
//  RefundDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

class RefundDialog: KLDialog<Double> {
    
    private var viewModel: RefundDVM
    
    private let amount = KLCashField()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Double>) {
        guard let vm = vm as? RefundDVM else {
            fatalError("Expecting RefundDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [(amount, cashKeyboard)]
    }
    
    override func makeDialogContentView() -> UIView? {
        let content = UIView()
        
        amount.placeholder = "Refund Amount"
        amount.font = theme.xxlargeInputFont
        amount.placeholderActiveScale = 0.45
        amount.placeholderVerticalOffset = 48.0
        amount.textColor = theme.textColor
        amount.value = 0
        content.addSubview(amount)
        amount.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(theme.guideline*2)
            make.right.equalToSuperview().offset(-theme.guideline * 2)
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
        
        _ = viewModel
            .dialogDidAppear
            .subscribe(onNext: { _ in
                _ = self.amount.becomeFirstResponder()
            })
    }
}
