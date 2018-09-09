//
//  CashPromptDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

/// For displaying of Cash Prompt
class CashPromptDialog: KLDialog<PayBillInfo> {
    override var dialogWidth: CGFloat { return 320 }
    override var dialogHeight: CGFloat { return 240 }
    
    private var viewModel: CashPromptDVM
    
    let message = UILabel()
    let ok = KLFlatButton()
    let cancel = KLFlatButton()
    let content = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<PayBillInfo>) {
        guard let vm = vm as? CashPromptDVM else {
            fatalError("Expecting CashPromptDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    /// No toolbar
    override func makeDialogToolbar() -> UIView? {
        return nil
    }
    
    override func makeDialogContentView() -> UIView? {
        message.numberOfLines = 2
        message.textAlignment = .center
        let title = NSMutableAttributedString(string: "CHANGE $$:\n", attributes: [
            NSAttributedStringKey.font: theme.heading1BoldFont,
            NSAttributedStringKey.foregroundColor: theme.textColor])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = 80
        title.append(NSAttributedString(string: viewModel.changeAmount.asMoney, attributes: [
            NSAttributedStringKey.font: RobotoFont.bold(with: 48.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.foregroundColor: theme.warn.base]))
        message.attributedText = title
        message.textAlignment = .center
        content.addSubview(message)
        
        ok.titleLabel?.font = theme.heading2Font
        ok.setTitleColor(theme.warn.base, for: .normal)
        ok.setTitle("OK", for: .normal)
        content.addSubview(ok)
        
        cancel.titleLabel?.font = theme.heading2Font
        cancel.setTitleColor(theme.primary.base, for: .normal)
        cancel.setTitle("CANCEL", for: .normal)
        content.addSubview(cancel)
        
        return content
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        message.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.theme.guideline*4)
            make.width.centerX.equalToSuperview()
        }
        
        ok.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.trailing.equalTo(self.content.snp.centerX)
            make.height.equalTo(self.theme.largeButtonHeight)
        }
        
        cancel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.leading.equalTo(self.content.snp.centerX)
            make.height.equalTo(self.theme.largeButtonHeight)
        }
    }
    
    override func prepare() {
        super.prepare()
        ok.rx.tap
            .map { self.viewModel.payInfo }
            .bind(to: self.viewModel.closeDialog)
            .disposed(by: disposeBag)
        cancel.rx.tap
            .map { nil }
            .bind(to: self.viewModel.closeDialog)
            .disposed(by: disposeBag)
    }
}
