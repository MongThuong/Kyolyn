//
//  KLDataTableColumn.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

fileprivate let cellSpacing: CGFloat = 12.0

enum KLDataTableColumnType {
    /// For displaying columns: OrderNo, TransNo, Quantity, Closing, Opening, Guests
    case number
    case largeNumber
    /// For displaying money
    case currency
    /// For adjusting tip
    case tip
    /// For displaying variable width string text
    case name
    /// For displaying lock icon on locked order
    case lockIcon
    /// For displaying checkbox specificially to Orders list
    case checkbox
    /// For displaying time/date
    case time
    /// For displaying status
    case status
    /// For displaying phone
    case phone
    /// For displaying email
    case email
    /// For displaying address
    case address
    /// For displaying card number
    case cardNumber
    /// For displaying card type
    case cardType
    /// For displaying card type
    case transType
    
    var alignment: NSTextAlignment {
        switch self {
        case .number: return .right
        case .largeNumber: return .right
        case .currency: return .right
        case .tip: return .right
        case .name: return .left
        case .lockIcon: return .center
        case .checkbox: return .center
        case .time: return .center
        case .status: return .left
        case .phone: return .left
        case .email: return .left
        case .address: return .left
        case .cardType: return .left
        case .cardNumber: return .left
        case .transType: return .left
        }
    }
    
    var width: CGFloat {
        switch self {
        case .number: return 48
        case .largeNumber: return 64
        case .currency: return 96
        case .tip: return 96
        case .name: return 64
        case .lockIcon: return 20
        case .checkbox: return 44
        case .time: return 52
        case .status: return 48
        case .phone: return 128
        case .email: return 64
        case .address: return 64
        case .cardType: return 80
        case .cardNumber: return 48
        case .transType: return 80
        }
    }
    
    var fixedWidth: Bool {
        return self != .name && self != .address  && self != .email && self != .transType
    }
}

typealias KLDataTableFormatCell<T> = (_ obj: T, _ cell: UIView, _ disposeBag: DisposeBag) -> Void

/// Column definition
struct KLDataTableColumn<T> {
    let name: NSAttributedString
    let type: KLDataTableColumnType
    let value: (_ obj: T) -> String
    let format: KLDataTableFormatCell<T>
    
    let lines: Int
    
    init(name: String, type: KLDataTableColumnType, lines: Int = 1, value: @escaping (_ obj: T) -> String, format: @escaping KLDataTableFormatCell<T> = { (_, _, _) in }) {
        self.init(name: NSAttributedString(string: name), type: type, lines: lines, value: value, format: format)
    }
    
    init(name: NSAttributedString, type: KLDataTableColumnType, lines: Int = 1, value: @escaping (_ obj: T) -> String, format: @escaping KLDataTableFormatCell<T> = { (_, _, _) in }) {
        self.name = name
        self.type = type
        self.lines = lines
        self.value = value
        self.format = format
    }    
}
