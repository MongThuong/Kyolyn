//
//  ProgressDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit
import DRPLoadingSpinner

class ProgressDialog: KLDialog<Void> {
    private let viewModel: ProgressDVM
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Void>) {
        guard let vm = vm as? ProgressDVM else {
            fatalError("Expecting ProgressDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override var dialogWidth: CGFloat { return 280 }
    override var dialogHeight: CGFloat { return 100 }
    
    override func makeDialogToolbar() -> UIView? {
        return nil
    }
    
    override func makeKeyboard() -> UIView? {
        return nil
    }
    
    fileprivate let progress = DRPLoadingSpinner()
    fileprivate let message = UILabel()
    
    override func makeDialogContentView() -> UIView? {
        let dialog = UIView()
        
        let wrapper = UIStackView()
        wrapper.axis = .horizontal
        wrapper.alignment = .center
        wrapper.distribution = .fill
        wrapper.spacing = theme.guideline
        dialog.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline*2)
        }
        
        progress.colorSequence = [theme.primary.base]
        progress.lineWidth = 3
        progress.startAnimating()
        progress.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        progress.setContentHuggingPriority(.defaultLow, for: .horizontal)
        wrapper.addArrangedSubview(progress)
        progress.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(40)
            make.leading.centerY.equalToSuperview()
        }
        
        message.adjustsFontSizeToFitWidth = true
        message.minimumScaleFactor = 0.8
        message.attributedText = NSAttributedString(string: viewModel.message, attributes: theme.messageBoxTextAttributes)
        message.numberOfLines = 3
        wrapper.addArrangedSubview(message)

        return dialog
    }
}
