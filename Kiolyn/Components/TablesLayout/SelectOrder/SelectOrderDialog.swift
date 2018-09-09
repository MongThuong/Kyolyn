//
//  SelectClockoutReason.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

/// This dialog is so simple, so don't split it up to View Model but mix the logic of View and ViewModel here.
class SelectOrderDialog : SelectItemDialog<Order> {
    override var cellType: AnyClass { return SelectOrderTableViewCell.self }
    override var cellHeight: CGFloat { return theme.largeButtonHeight }
}
