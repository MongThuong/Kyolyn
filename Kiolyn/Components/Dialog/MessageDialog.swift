//
//  MessageDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/30/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

class MessageDialog: KLDialog<MessageDR> {
    
    private let viewModel: MessageDVM
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<MessageDR>) {
        guard let vm = vm as? MessageDVM else {
            fatalError("Expecting MessageDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }

    override var dialogWidth: CGFloat { return 440 }
    override var dialogHeight: CGFloat { return 200 }
    
    override func makeDialogToolbar() -> UIView? {
        return nil
    }
    
    override func makeKeyboard() -> UIView? {
        return nil
    }
    
    fileprivate let icon = UILabel()
    fileprivate let message = UILabel()
    fileprivate let bar = UIStackView()
    fileprivate let no = MessageDialogButton(theme: Theme.dialogTheme)
    fileprivate let yes = MessageDialogButton(theme: Theme.dialogTheme)
    fileprivate let neutral = MessageDialogButton(theme: Theme.dialogTheme)
    
    override func makeDialogContentView() -> UIView? {
        let dialog = UIView()
        
        let wrapper = UIView()
        dialog.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy((dialogWidth - theme.guideline*4)/dialogWidth)
            make.height.equalToSuperview().multipliedBy((dialogHeight - theme.guideline*8)/dialogHeight)
        }
        
        yes.title = viewModel.yesText
        no.title = viewModel.noText
        neutral.title = viewModel.neutralText
        
        no.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        yes.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        bar.alignment = .center
        bar.distribution = .fill
        bar.axis = .horizontal
        bar.semanticContentAttribute = .forceRightToLeft
        bar.addArrangedSubview(no)
        bar.addArrangedSubview(yes)
        bar.addArrangedSubview(neutral)

        wrapper.addSubview(bar)
        bar.snp.makeConstraints { make in
            make.bottom.width.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        switch viewModel.type {
        case .info:
            no.title = "CLOSE"
            yes.alpha = 0
            neutral.alpha = 0
            icon.textColor = theme.primary.base
            icon.fakIcon = FAKFontAwesome.exclamationCircleIcon(withSize: theme.messageBoxIconSize)
        case .error:
            no.title = "CLOSE"
            yes.alpha = 0
            neutral.alpha = 0
            icon.textColor = theme.warn.base
            icon.fakIcon = FAKFontAwesome.exclamationTriangleIcon(withSize: theme.messageBoxIconSize)
        case .confirm:
            neutral.alpha = viewModel.neutralText.isEmpty ? 0 : 1
            icon.textColor = theme.primary.base
            icon.fakIcon = FAKFontAwesome.questionIcon(withSize: theme.messageBoxIconSize)
        }
        icon.textAlignment = .center
        wrapper.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(theme.guideline)
            make.width.equalToSuperview().multipliedBy(0.15)
        }
        
        message.adjustsFontSizeToFitWidth = true
        message.minimumScaleFactor = 0.8
        message.attributedText = NSAttributedString(string: viewModel.message, attributes: theme.messageBoxTextAttributes)
        message.numberOfLines = 3
        wrapper.addSubview(message)
        message.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(theme.guideline)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        no.rx.tap.map { _ in .no }.bind(to: viewModel.closeDialog).disposed(by: disposeBag)
        yes.rx.tap.map { _ in .yes }.bind(to: viewModel.closeDialog).disposed(by: disposeBag)
        neutral.rx.tap.map { _ in .neutral }.bind(to: viewModel.closeDialog).disposed(by: disposeBag)
        
        return dialog
    }
}

fileprivate class MessageDialogButton: KLFlatButton {
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: max(88, size.width), height: max(theme.buttonHeight, size.height))
    }
    
    override func prepare() {
        super.prepare()
        titleLabel?.font = theme.normalFont
        titleLabel?.numberOfLines = 2
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleColor = theme.primary.base
    }
}
