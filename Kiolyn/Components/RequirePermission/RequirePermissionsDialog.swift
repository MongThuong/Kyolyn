//
//  RequirePermissionsDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/18/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// For asking for permission passkey.
class RequirePermissionsDialog: KLDialog<Employee> {
    
    private let viewModel: RequirePermissionsDVM
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Employee>) {
        guard let vm = vm as? RequirePermissionsDVM else {
            fatalError("Expecting RequirePermissionsDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }

    /// The passkey input text field
    fileprivate let passkey = KLTextField()
    /// For displaying error message from Signin/Remote Sync
    fileprivate let errorLabel = UILabel()
    /// The input keyboard
    fileprivate let passkeyKeyboard = PasskeyKeyboard()

    override var dialogWidth: CGFloat { return 304 }
    override var dialogHeight: CGFloat { return 424 }

    override func makeDialogToolbar() -> UIView? {
        return nil
    }
    
    override func makeKeyboard() -> UIView? {
        return nil
    }

    override func makeDialogContentView() -> UIView? {
        let dialog = UIView()

        passkey.placeholder = "PASSKEY"
        passkey.font = theme.xxlargeInputFont
        passkey.placeholderActiveScale = 0.45
        passkey.placeholderVerticalOffset = 20.0
        passkey.detailVerticalOffset = 4.0
        passkey.textAlignment = .center
        passkey.isSecureTextEntry = true
        dialog.addSubview(passkey)
        passkey.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalToSuperview().offset(theme.guideline)
            make.height.equalToSuperview().multipliedBy(theme.largeInputHeight/dialogHeight)
        }
        passkey.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .map { $0.isNotEmpty }
            .bind(to: passkeyKeyboard.returnButton!.rx.isEnabled)
            .disposed(by: disposeBag)

        errorLabel.text = "Please input passkey."
        errorLabel.textAlignment = .center
        errorLabel.font = theme.normalFont
        errorLabel.textColor = theme.warn.base
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.minimumScaleFactor = 0.5
        dialog.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.top.equalTo(passkey.snp.bottom).offset(theme.guideline)
            make.height.equalToSuperview().multipliedBy(theme.normalInputHeight/dialogHeight)
        }
        viewModel.error
            .asDriver()
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)

        dialog.addSubview(passkeyKeyboard)
        passkeyKeyboard.snp.makeConstraints { make in
            make.centerX.width.bottom.equalToSuperview()
            make.top.equalTo(errorLabel.snp.bottom)
        }
        passkeyKeyboard.textFields = [passkey]
        passkeyKeyboard.closeButton.rx.tap
            .map { _ -> Employee? in nil }
            .bind(to: viewModel.closeDialog)
            .disposed(by: disposeBag)
        passkeyKeyboard.returnButton!.rx.tap
            .map { self.passkey.text }
            .filterNil()
            .bind(to: viewModel.verify)
            .disposed(by: disposeBag)
        
        _ = viewModel.dialogDidAppear
            .subscribe(onNext: { _ in
                _ = self.passkey.becomeFirstResponder()
            })
        
        return dialog
    }
}
