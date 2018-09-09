//
//  AddNewModifierDialog.swift
//  Kiolyn
//
//  Created by Tien Pham on 10/26/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddNewModifierDialog: KLDialog<Modifier> {
    
    private var viewModel: AddNewModifierDVM
    private let noteTextField = KLTextField()
    private let priceCashField = KLCashField()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Modifier>) {
        guard let vm = vm as? AddNewModifierDVM else {
            fatalError("Expecting AddNewModifierDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override var dialogWidth: CGFloat { return 540 }
    override var dialogHeight: CGFloat { return 600 }
    
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [
            (noteTextField, self.textKeyboard),
            (priceCashField, self.numpad)
        ]
    }
    
    override func makeDialogContentView() -> UIView? {
        let view = UIView()
        
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.alignment = .fill
        wrapper.distribution = .fill
        wrapper.spacing = theme.guideline * 4
        view.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(theme.guideline * 2)
            make.right.equalToSuperview().offset(-theme.guideline * 2)
        }
        
        noteTextField.font = theme.largeInputFont
        noteTextField.placeholder = "Name"
        noteTextField.placeholderVerticalOffset = 32.0
        noteTextField.placeholderActiveScale = 0.45
        wrapper.addArrangedSubview(noteTextField)
        noteTextField.snp.makeConstraints { make in
            make.height.equalTo(theme.normalInputHeight)
        }
        
        priceCashField.value = 0
        priceCashField.font = theme.largeInputFont
        priceCashField.placeholder = "Price"
        priceCashField.placeholderVerticalOffset = 32.0
        priceCashField.placeholderActiveScale = 0.45
        priceCashField.textColor = theme.textColor
        wrapper.addArrangedSubview(priceCashField)
        priceCashField.snp.makeConstraints { make in
            make.height.equalTo(theme.normalInputHeight)
        }

        return view
    }
    
    override func prepare() {
        super.prepare()
        noteTextField.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)

        priceCashField.rx.doubleValue
            .asDriver()
            .drive(viewModel.price)
            .disposed(by: disposeBag)
        
        _ = viewModel.dialogDidAppear
            .subscribe(onNext: { _ in
                _ = self.noteTextField.becomeFirstResponder()
            })
    }
}
