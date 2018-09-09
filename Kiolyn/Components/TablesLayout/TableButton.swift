//
//  TableButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import RxSwift
import FontAwesomeKit

/// Table button, could be in rectangle/ellipse shapes.
class TableButton: KLFlatButton {
    var disposeBag: DisposeBag?

    let nameLabel = UILabel()
    let detailLabel = UILabel()
    let shapeLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    let lockedIcon = UILabel()
    let multipleIcon = UILabel()
    let checkIcon = UILabel()
    let holdIcon = UILabel()
    let icons = UIStackView()

    /// The source table
    var table: TableViewModel? {
        didSet {
            // Reset data
            self.isHidden = true
            self.frame = CGRect.zero
            self.nameLabel.text = ""
            // No table assigned, do nothing more
            guard let dbag = disposeBag, let table = table else {
                return
            }
            // Show the table
            self.isHidden = false
            // Size & Position
            let tbl = table.table
            let left = max(tbl.left - tbl.width/2, theme.guideline)
            let top = tbl.top - tbl.height/2
            self.frame = CGRect(x: left, y: top, width: tbl.width, height: tbl.height)
            // Shape
            let path: UIBezierPath!
            if tbl.shape == .rectangle {
                path = UIBezierPath(roundedRect: bounds, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 1, height: 1))
            } else {
                path = UIBezierPath(ovalIn: bounds)
            }
            maskLayer.path = path.reversing().cgPath
            shapeLayer.frame = bounds
            shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            shapeLayer.path = path.cgPath
            nameLabel.text = tbl.name

            // Reload based on orders changed
            table.tableState
                .drive(onNext: { state in self.update(state: state) })
                .disposed(by: dbag)
        }
    }
    
    private func update(state: TableState) {
        guard let table = self.table else {
            return
        }
        
        let (orders, lockedOrders, selectedTable, selectedOrder) = state
        for v in icons.arrangedSubviews {
            v.removeFromSuperview()
        }
        
        if table.area.isNotAutoIncrement {
            // Update colors
            shapeLayer.strokeColor = orders.isNotEmpty
                ? theme.warn.base.cgColor
                : theme.secondary.base.cgColor
            // Update text
            detailLabel.text  = { () -> String in
                // if this area is not prompting for guest, then show no guest info ????
                guard table.area.noOfGuestPrompt else { return "" }
                // if there is no orders, then just display the maximum number of guest of this table
                guard orders.count > 0 else {
                    return "\(table.table.maxGuests) Gst."
                }
                // if there is only one Order, show the OrderNo, otherwise show the orders count
                let detail = orders.count > 1 ? "x \(orders.count)" : "#\(orders.first!.orderNo)"
                // ... with total guests
                let guests = orders.reduce(0, { (g, o) -> UInt in return g + o.persons })
                return "(\(detail)) \(guests) Gst."
            }()
        } else {
            shapeLayer.strokeColor = theme.secondary.base.cgColor
            detailLabel.text = "\(table.orders.value.first?.total.asMoney ?? "")"
        }
        
        let hasLockedOrders = orders.any { lockedOrders.isLocked($0) }
        let multipleOrders = orders.count > 1
        let hasPrintedOrders = orders.contains { $0.isPrinted }
        let hasHoldItems = orders.contains { $0.hasHoldItems }
        let top = (hasLockedOrders || multipleOrders || hasPrintedOrders || hasHoldItems) ? theme.guideline*4 : theme.guideline*2
        let frame = self.frame
        nameLabel.frame = CGRect(x: 0, y: frame.height/2 - top, width: frame.width, height: 20)
        detailLabel.frame = CGRect(x: 0, y: frame.height/2 - top + 20, width: frame.width, height: 18)
        
        if hasLockedOrders { icons.addArrangedSubview(lockedIcon) }
        if multipleOrders { icons.addArrangedSubview(multipleIcon) }
        if hasPrintedOrders { icons.addArrangedSubview(checkIcon) }
        if hasHoldItems { icons.addArrangedSubview(holdIcon) }
        let iconsCount = icons.arrangedSubviews.count
        let iconsWidth = CGFloat(iconsCount * 18 + (iconsCount - 1) * 4)
        icons.frame = CGRect(x: (frame.width - iconsWidth)/2, y: frame.height/2 - top + 40, width: iconsWidth, height: 20)
        // Angle
        let radians = CGFloat(__sinpi(Double(table.table.angle/180.0)))
        transform = CGAffineTransform(rotationAngle: radians)
        
        // Selected status
        isSelected = table.table.id == selectedTable?.table.id
        // Enable status
        if let (mode, order) = selectedOrder {
            if mode == .move {
                isEnabled = !table.area.isAutoIncrement && order.table != table.table.id
            } else {
                isEnabled = orders.any({ o -> Bool in
                    o.id != order.id && o.mutable && o.bills.isEmpty && lockedOrders.isNotLocked(o)
                })
            }
        } else {
            isEnabled = true
        }
        
        // Now update layout
        setNeedsLayout()
    }
    

    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? theme.tableSelectedColor : UIColor.clear
        }
    }

    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        clipsToBounds = false

        // We need to clip the outside area
        maskLayer.fillRule = kCAFillRuleEvenOdd
        layer.mask = maskLayer

        layer.addSublayer(shapeLayer)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = CGFloat(theme.tableDashStrokeWidth)
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.lineCap = kCALineCapRound

        nameLabel.font = theme.normalFont
        nameLabel.textColor = theme.textColor
        nameLabel.textAlignment = .center
        addSubview(nameLabel)

        detailLabel.font = theme.smallFont
        detailLabel.textColor = theme.textColor
        detailLabel.alpha = 0.75
        detailLabel.textAlignment = .center
        addSubview(detailLabel)

        icons.axis = .horizontal
        icons.distribution = .fill
        icons.alignment = .center
        icons.spacing = 4.0
        icons.isUserInteractionEnabled = false
        addSubview(icons)

        lockedIcon.textColor = theme.warn.base
        lockedIcon.fakIcon = FAKFontAwesome.lockIcon(withSize: 18.0)
        lockedIcon.isUserInteractionEnabled = false

        multipleIcon.textColor = theme.secondary.base
        multipleIcon.fakIcon = FAKFontAwesome.filesOIcon(withSize: 18.0)
        multipleIcon.isUserInteractionEnabled = false

        checkIcon.textColor = theme.secondary.base
        checkIcon.fakIcon = FAKFontAwesome.checkIcon(withSize: 18.0)
        checkIcon.isUserInteractionEnabled = false

        holdIcon.textColor = theme.secondary.base
        holdIcon.fakIcon = FAKFontAwesome.handPaperOIcon(withSize: 18.0)
        holdIcon.isUserInteractionEnabled = false
    }
}

