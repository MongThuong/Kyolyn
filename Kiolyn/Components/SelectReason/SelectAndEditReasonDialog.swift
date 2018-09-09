//
//  SelectAndEditDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/10/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// Select and edti reason
class SelectAndEditReasonDialog: KLDialog<String> {
    
    let reasons = KLTableView()
    let reason = KLTextField()
    
    /// The correspondence view model
    private var viewModel: SelectAndEditReasonDVM
    
    override var dialogHeight: CGFloat { return 480 }
    
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [(reason, textKeyboard)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<String>) {
        self.viewModel = vm as! SelectAndEditReasonDVM
        super.init(vm)
    }
    
    /// Build the table layout
    ///
    /// - Returns: The dialog content view.
    override func makeDialogContentView() -> UIView? {
        let content = UIView()
        
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.alignment = .fill
        wrapper.distribution = .fill
        wrapper.spacing = theme.guideline * 2
        
        reason.placeholder = "Reason"
        reason.font = theme.normalFont
        reason.placeholderActiveScale = 0.5
        reason.placeholderVerticalOffset = 18
        reason.setContentHuggingPriority(.defaultLow, for: .vertical)
        wrapper.addArrangedSubview(reason)
        
        reasons.rowHeight = theme.normalButtonHeight
        reasons.register(SelectItemTableViewCell<Reason>.self, forCellReuseIdentifier: "Cell")
        wrapper.addArrangedSubview(reasons)
        
        content.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline*2)
        }
        
        return content
    }
    
    /// Prepare the binding.
    override func prepare() {
        super.prepare()
        
        _ = viewModel.dialogDidAppear
            .subscribe(onNext: { _ = self.reason.becomeFirstResponder() })
        
        // Should happen once
        _ = Observable.just(viewModel.reasons)
            .bind(to: reasons.rx.items) { (tableView, row, reason) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SelectItemTableViewCell<Reason>
                cell.item = reason
                return cell
        }
        reasons.rx.modelSelected(Reason.self)
            .map { $0.name }
            .bind(to: reason.rx.text)
            .disposed(by: disposeBag)
        reasons.rx.modelSelected(Reason.self)
            .map { $0.name }
            .bind(to: viewModel.reason)
            .disposed(by: disposeBag)
        
        reason.rx.text.orEmpty.changed
            .bind(to: viewModel.reason)
            .disposed(by: disposeBag)
    }
}

