//
//  CustomerTableViewCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/1/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For layout the area information.
class CustomerTableViewCell: KLTableViewCell {
    private let theme =  Theme.dialogTheme
    
    let name = UILabel()
    let email = UILabel()
    let phone = UILabel()
    let address = UILabel()
    
    /// Area of this cell.
    var customer: Customer? {
        didSet {
            guard let customer = customer else { return }
            name.text = customer.name
            email.attributedText = self.name("Email", value: customer.email)
            phone.attributedText = self.name("Phone", value: customer.mobilephone.formattedPhone)
            address.attributedText = self.name("Address", value: "\(customer.address)")
        }
    }
    
    func label(_ l: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: l, attributes: [
            NSAttributedStringKey.font: theme.xsmallFont,
            NSAttributedStringKey.foregroundColor: theme.secondaryTextColor])
    }
    
    func value(_ v: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: v, attributes: [
            NSAttributedStringKey.font: theme.xsmallFont,
            NSAttributedStringKey.foregroundColor: theme.textColor])
    }
    
    func name(_ n: String, value v: String) -> NSMutableAttributedString {
        let string = label("\(n): ")
        string.append(value(v))
        return string
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = UIColor.clear
        
        name.textColor = theme.primary.base
        name.font = theme.normalBoldFont
        addSubview(name)
        name.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(theme.guideline/2)
            make.trailing.equalToSuperview().offset(-theme.guideline/2)
        }
        
        addSubview(email)
        email.textColor = theme.textColor
        email.font = theme.smallFont
        email.snp.makeConstraints { make in
            make.leading.trailing.equalTo(name)
            make.top.equalTo(self.name.snp.bottom)
        }
        
        addSubview(phone)
        phone.textColor = theme.textColor
        phone.font = theme.smallFont
        phone.snp.makeConstraints { make in
            make.leading.trailing.equalTo(name)
            make.top.equalTo(self.email.snp.bottom)
        }
        
        addSubview(address)
        address.textColor = theme.textColor
        address.font = theme.smallFont
        address.snp.makeConstraints { make in
            make.leading.trailing.equalTo(name)
            make.top.equalTo(self.phone.snp.bottom)
        }
        
        let separator = KLSeparator(theme)
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.bottom.width.equalToSuperview()
        }
    }
}
