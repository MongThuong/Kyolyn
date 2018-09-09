//
//  OrderButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import RxSwift

/// Type of buttons
enum OrderButtonType {
    case customer
    case driver
    case delivered
}

/// For displaying Order related button.
class OrderButton: KLFlatButton {
    private let dashPattern : [CGFloat] = [4, 2]

    var disposeBag: DisposeBag?
    var type: OrderButtonType = .customer

    var order: Order? = nil {
        didSet {
            // Check if we have order
            guard let order = order else { return }
            switch type {
            case .customer:
                if order.hasCustomer {
                    title = "\(order.customerLine1)\n\(order.customerLine2)\n\(order.customerLine3)"
                    titleLabel?.font = theme.normalFont
                    titleLabel?.numberOfLines = 3
                } else {
                    title = "NO CUSTOMER INFO"
                    titleLabel?.font = theme.heading3Font
                    titleLabel?.numberOfLines = 1
                }
            case .driver:
                if order.hasDriver {
                    title = order.driverName.uppercased()
                    titleLabel?.font = theme.normalFont
                    titleLabel?.numberOfLines = 2
                        titleLabel?.lineBreakMode = .byWordWrapping
                } else {
                    title = "SELECT\nDRIVER"
                    titleLabel?.font = theme.heading3Font
                    titleLabel?.numberOfLines = 2
                }
            case .delivered:
                titleLabel?.font = theme.heading3Font
                titleLabel?.numberOfLines = 2
                if order.delivered {
                    title = "DELIVERED"
                } else {
                    switch order.orderStatus {
                    case .new:
                        title = "NEW"
                    case .submitted:
                        title = "SENT"
                    case .printed:
                        title = "CHECKED"
                    case .checked:
                        title = "PAID\nDelivered?"
                    case .voided:
                        title = "VOIDED"
                    }
                }
            }
        }
    }

    override func prepare() {
        super.prepare()
        titleLabel?.textAlignment = .center
        titleLabel?.textColor = theme.secondaryTextColor
    }

    /// Override for drawing the dashed border around the content.
    ///
    /// - Parameter rect: The drawing rect.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        // Transaparent background
        UIColor.clear.setFill()
        path.fill()
        // Border color
        theme.primary.base.setStroke()
        path.lineWidth = theme.tableDashStrokeWidth
        path.setLineDash(dashPattern, count: 2, phase: 0)
        path.stroke()
        // Draw the main content
        super.draw(rect)
    }
}
