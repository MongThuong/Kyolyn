//
//  CreditCardDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import DRPLoadingSpinner
import FontAwesomeKit
import Material

class CreditCardDialog: KLDialog<Transaction> {
    override var dialogHeight: CGFloat { return 280 }
    
    let viewModel: CreditCardDVM

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Transaction>) {
        guard let vm = vm as? CreditCardDVM else {
            fatalError("Expecting CreditCardDVM")
        }
        viewModel = vm
        super.init(vm)
    }

    fileprivate let bar = UIStackView()
    fileprivate let retry = CCDialogButton(theme: Theme.dialogTheme)
//    fileprivate let approve = CCDialogButton(theme: Theme.dialogTheme)
//    fileprivate let cancel = CCDialogButton(theme: Theme.dialogTheme)

    fileprivate var loading = DRPLoadingSpinner()
    fileprivate let icon = UILabel()
    fileprivate let message = UILabel()
    fileprivate let device = UILabel()
    
    override func makeDialogContentView() -> UIView? {
        let dialog = UIView()
        
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.alignment = .fill
        wrapper.distribution = .fill
        wrapper.spacing = theme.guideline * 2
        dialog.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(theme.guideline * 2)
            make.bottom.equalToSuperview().offset(-theme.guideline)
            make.leading.equalToSuperview().offset(theme.guideline * 4)
            make.trailing.equalToSuperview().offset(-theme.guideline * 4)
        }
        
        // DEVICE INFO
        device.textColor = theme.textColor
        device.font = theme.heading1Font
        device.adjustsFontSizeToFitWidth = true
        device.minimumScaleFactor = 0.8
        wrapper.addArrangedSubview(device)
        viewModel.deviceInfo
            .drive(device.rx.text)
            .disposed(by: disposeBag)
        
        // MAIN CONTENT
        let contentWrapper = UIStackView()
        contentWrapper.axis = .horizontal
        contentWrapper.alignment = .center
        contentWrapper.distribution = .fill
        contentWrapper.spacing = theme.guideline * 2
        
        let loadingSize = theme.normalButtonHeight
        loading.frame = CGRect(x: 0, y: 0, width: loadingSize, height: loadingSize)
        loading.colorSequence = [theme.primary.base]
        loading.lineWidth = 4
        loading.startAnimating()
        loading.isHidden = true
        contentWrapper.addArrangedSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.equalTo(loadingSize)
        }
        
        icon.isHidden = true
        icon.textAlignment = .center
        icon.textColor = theme.warn.base
        icon.fakIcon = FAKFontAwesome.exclamationTriangleIcon(withSize: 40)
        contentWrapper.addArrangedSubview(icon)
        icon.snp.makeConstraints { make in
            make.width.equalTo(loadingSize)
        }

        message.numberOfLines = 5
        message.textColor = theme.textColor
        message.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentWrapper.addArrangedSubview(message)

        contentWrapper  .setContentHuggingPriority(.defaultLow, for: .vertical)
        wrapper.addArrangedSubview(contentWrapper)

        // BAR
//        approve.title = "APPROVE"
//        cancel.title = "CANCEL"
        retry.title = "RETRY"
        retry.isHidden = true
        bar.addArrangedSubview(retry)
        retry.rx.tap
            .bind(to: viewModel.request)
            .disposed(by: disposeBag)
//        if viewModel.device.isStandalone {
//            bar.addArrangedSubview(approve)
//            bar.addArrangedSubview(cancel)
//        }
        bar.alignment = .center
        bar.distribution = .fillEqually
        bar.axis = .horizontal
        bar.setContentHuggingPriority(.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(bar)
        bar.snp.makeConstraints { make in
            make.height.equalTo(self.theme.buttonHeight)
        }
        
        viewModel.status
            .asDriver()
            .drive(onNext: { status in self.update(layout: status) })
            .disposed(by: disposeBag)

//        reprint.rx.tap
//            .bind(to: viewModel.reprint)
//            .disposed(by: disposeBag)
//        cancel.rx.tap
//            .map { _ -> Transaction? in nil }
//            .bind(to: viewModel.closeDialog)
//            .disposed(by: disposeBag)
//        approve.rx.tap
//            .bind(to: viewModel.approve)
//            .disposed(by: disposeBag)

        return dialog
    }
    
    private func update(layout status: ViewStatus) {
        switch status {
        case let .message(m):
            dialogCloseButton.isEnabled = false
            loading.startAnimating()
            loading.isHidden = false
            icon.isHidden = true
            let attrString = NSMutableAttributedString()
            attrString.append(NSAttributedString(string: m, attributes: [
                NSAttributedStringKey.font: theme.normalFont,
                NSAttributedStringKey.foregroundColor: theme.textColor]))
            message.attributedText = attrString
            retry.isHidden = true
//            approve.isHidden = true
//            cancel.isHidden = true
        case let .error(detail):
            dialogCloseButton.isEnabled = true
            loading.stopAnimating()
            loading.isHidden = true
            icon.isHidden = false
            icon.textColor = theme.warn.base
            icon.fakIcon = FAKFontAwesome.exclamationTriangleIcon(withSize: 40)
            let attrString = NSMutableAttributedString()
            attrString.append(NSAttributedString(string: "DENIED\n", attributes: [
                NSAttributedStringKey.font: theme.subTitleFont,
                NSAttributedStringKey.foregroundColor: theme.warn.base]))
            attrString.append(NSAttributedString(string: detail, attributes: [
                NSAttributedStringKey.font: theme.normalFont,
                NSAttributedStringKey.foregroundColor: theme.textColor]))
            
            message.attributedText = attrString
            retry.isHidden = false
//            approve.isHidden = true
//            cancel.isHidden = true
        case .ok:
            dialogCloseButton.isEnabled = true
            loading.stopAnimating()
            loading.isHidden = true
            icon.isHidden = false
            icon.textColor = theme.primary.base
            icon.fakIcon = FAKFontAwesome.checkCircleIcon(withSize: 40)
            let attrString = NSMutableAttributedString()
            attrString.append(NSAttributedString(string: "APPROVED", attributes: [
                NSAttributedStringKey.font: theme.subTitleFont,
                NSAttributedStringKey.foregroundColor: theme.primary.base]))
            message.attributedText = attrString
            retry.isHidden = true
//            approve.isHidden = true
//            cancel.isHidden = true
        default: break
        }
    }
}

class CreditRefundDialog: CreditCardDialog { }
class CreditForceDialog: CreditCardDialog { }
class CreditSaleDialog: CreditCardDialog { }
class CreditVoidDialog: CreditCardDialog { }

