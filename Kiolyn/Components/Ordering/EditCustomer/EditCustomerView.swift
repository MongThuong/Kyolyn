//
//  EditCustomerView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/1/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import FontAwesomeKit

/// The view for editing customer.
class EditCustomerView: KLView {
    let theme = Theme.dialogTheme
    let disposeBag = DisposeBag()
    
    let inputs = UIView()
    let fields = UIStackView()
    let name = KLTextField()
    let phone = KLTextField()
    let email = KLTextField()
    let address = KLTextField()
    let clear = KLFlatButton()
    
    let emptyResult = KLView()
    let leftArrow = UILabel()
    let emptyText = UILabel()
    
    let result = KLTableView()
    
    override func prepare() {
        super.prepare()
        
        clear.title = "CLEAR"
        clear.titleColor = theme.warn.base
        clear.titleLabel?.font = theme.normalFont
        inputs.addSubview(clear)
        
        fields.axis = .vertical
        fields.distribution = .fill
        fields.alignment = .fill
        inputs.addSubview(fields)
        
        name.font = theme.normalInputFont
        name.placeholder = "Name"
        name.placeholderVerticalOffset = 16.0
        name.detailVerticalOffset = 4.0
        name.textColor = theme.textColor
        name.setContentHuggingPriority(.defaultHigh, for: .vertical)
        fields.addArrangedSubview(name)
        
        phone.font = theme.normalInputFont
        phone.placeholder = "Phone"
        phone.placeholderVerticalOffset = 16.0
        phone.detailVerticalOffset = 4.0
        phone.textColor = theme.textColor
        phone.setContentHuggingPriority(.defaultHigh, for: .vertical)
        // For fixing #KIO-679 https://willbe.atlassian.net/browse/KIO-679
        phone.rx.text.changed.subscribe(onNext: { text in
            self.phone.text = text?.formattedPhoneNumber() ?? ""
        }).disposed(by: disposeBag)
        fields.addArrangedSubview(phone)
        
        email.font = theme.normalInputFont
        email.placeholder = "Email"
        email.placeholderVerticalOffset = 16.0
        email.detailVerticalOffset = 4.0
        email.textColor = theme.textColor
        email.autocapitalizationType = .none
        email.setContentHuggingPriority(.defaultHigh, for: .vertical)
        fields.addArrangedSubview(email)
        
        address.font = theme.normalInputFont
        address.placeholder = "Address"
        address.placeholderVerticalOffset = 16.0
        address.detailVerticalOffset = 4.0
        address.textColor = theme.textColor
        address.setContentHuggingPriority(.defaultHigh, for: .vertical)
        fields.addArrangedSubview(address)
        
        addSubview(inputs)
        
        result.rowHeight = theme.mediumButtonHeight
        result.register(CustomerTableViewCell.self, forCellReuseIdentifier: "Cell")
        result.rowHeight = theme.xlargeButtonHeight + 16
        addSubview(result)
        
        // The left arrow to prompt user to refine their search
        leftArrow.textColor = theme.othersTextColor
        leftArrow.fakIcon = FAKFontAwesome.arrowCircleLeftIcon(withSize: theme.mediumIconButtonHeight)
        emptyResult.addSubview(leftArrow)
        // The empty text below the error to clarify the idea of refining search
        emptyText.textColor = theme.othersTextColor
        emptyText.text = "Please refine your search."
        emptyText.font = theme.heading2Font
        emptyResult.addSubview(emptyText)
        // The empty view to display when there is no matching customer
        emptyResult.alpha = 0.5
        addSubview(emptyResult)        
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        inputs.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(theme.guideline)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        clear.snp.makeConstraints { make in
            make.leading.bottom.width.equalToSuperview()
            make.height.equalTo(theme.buttonHeight)
        }
        
        fields.spacing = theme.guideline*2
        fields.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
        }
        
        result.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(inputs.snp.trailing).offset(theme.guideline*2)
        }
        
        leftArrow.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-theme.mediumIconButtonHeight)
        }
        emptyText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(leftArrow.snp.bottom)
        }
        emptyResult.snp.makeConstraints { make in
            make.edges.equalTo(self.result.snp.edges)
        }
    }
}


