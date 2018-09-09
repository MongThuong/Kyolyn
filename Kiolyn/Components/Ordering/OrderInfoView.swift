//
//  OrderInfoView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For displaying Order's information like area/table/guests/date time.
class OrderInfo: KLView {
    private let theme =  Theme.mainTheme
    
    let area = UILabel()
    let table = UILabel()
    let time = UILabel()
    let orderNoGuest = UILabel()
    
    var order: Order? {
        didSet {
            guard let order = self.order else { return }
            area.attributedText = name("Area", value: "\(order.areaName)")
            table.attributedText = name("Table", value: "\(order.tableName)")
            time.attributedText = name("Time", value: "\(order.createdTime.toString("MMM d HH:mm"))")
            let orderNoGuestString = name("Ord.#", value: "\(order.orderNo)")
            orderNoGuestString.append(label(" - "))
            orderNoGuestString.append(name("#Gst.", value: "\(order.persons)"))
            orderNoGuest.attributedText = orderNoGuestString
        }
    }
    
    func label(_ l: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: l, attributes: [
            NSAttributedStringKey.font: theme.smallFont,
            NSAttributedStringKey.foregroundColor: theme.secondaryTextColor])
    }
    
    func value(_ v: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: v, attributes: [
            NSAttributedStringKey.font: theme.smallFont,
            NSAttributedStringKey.foregroundColor: theme.textColor])
    }
    
    func name(_ n: String, value v: String) -> NSMutableAttributedString {
        let string = label("\(n): ")
        string.append(value(v))
        return string
    }
    
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        // AREA
        addSubview(area)
        area.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.top.equalToSuperview()
        }
        
        // TABLE
        addSubview(table)
        table.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.bottom.equalToSuperview()
        }
        
        // TIME
        addSubview(time)
        time.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.top.equalToSuperview()
        }
        
        // Order number and number of guests
        addSubview(orderNoGuest)
        let orderNoGuestString = name("Ord.#", value: "0")
        orderNoGuestString.append(label(" - "))
        orderNoGuestString.append(name("#Gst.", value: "0"))
        orderNoGuest.attributedText = orderNoGuestString
        orderNoGuest.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.bottom.equalToSuperview()
        }
    }
}
