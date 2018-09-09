//
//  SelectOrderTableViewCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/8/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
/// For displaying Order inside table view.
class SelectOrderTableViewCell: SelectItemTableViewCell<Order> {
    let orderNoLabel = UILabel()
    let timeLabel = UILabel()
    let amountLabel = UILabel()
    
    override var item: Order? {
        didSet {
            guard let order = item else { return }
            orderNoLabel.text = "#\(order.orderNo)"
            timeLabel.text = order.createdTime.toString("MMM d HH:mm")
            amountLabel.text = order.total.asMoney
        }
    }
    
    override func prepare() {
        super.prepare()
        
        amountLabel.textColor = theme.textColor
        amountLabel.font = theme.heading1BoldFont
        amountLabel.textAlignment = .right
        addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        orderNoLabel.textColor = theme.textColor
        orderNoLabel.font = theme.heading2BoldFont
        addSubview(orderNoLabel)
        orderNoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline)
            make.top.equalToSuperview().offset(theme.guideline/2)
            make.width.equalToSuperview().multipliedBy(0.65)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        
        timeLabel.textColor = theme.secondaryTextColor
        timeLabel.font = theme.normalFont
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline)
            make.bottom.equalToSuperview().offset(-theme.guideline/2)
            make.width.equalToSuperview().multipliedBy(0.65)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
    }
}
