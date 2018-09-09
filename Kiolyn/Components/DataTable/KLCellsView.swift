//
//  KLCellsView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

class KLCellsView: UIView {
    
    var cells: [(UIView, KLDataTableColumnType)] = [] {
        didSet {
            for v in subviews {
                v.removeFromSuperview()
            }
            for c in cells {
                addSubview(c.0)
            }
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let fixedWidth: CGFloat = cells.reduce(0) { (width, cell) in
            width + (cell.1.fixedWidth ? cell.1.width : 0)
        }
        let dynamicCellCount: CGFloat =  CGFloat(cells.filter { !$0.1.fixedWidth }.count)
        let dynamicWidth: CGFloat = max((frame.size.width - fixedWidth) / dynamicCellCount, 0)
        var x: CGFloat = 0
        for (view, type) in cells {
            let w = type.fixedWidth ? type.width : dynamicWidth
            view.frame = CGRect(x: x + 4, y: 0, width: w - 8, height: frame.size.height)
            x += w
        }
    }
    
    //    lazy var textHeight: CGFloat = {
    //        return theme.xsmallFont.stringSize(string: "", constrainedTo: CGFloat(Int.max)).height
    //    }()
    //
    //    override func draw(_ rect: CGRect) {
    //        super.draw(rect)
    //        // Make sure we have sth to draw
    //        guard let columns = columns, columns.isNotEmpty else {
    //            return
    //        }
    //        let fixedWidth: CGFloat = columns.reduce(0) { (width, col) in
    //            width + (col.type.fixedWidth ? col.type.width : 0)
    //        }
    //        let dynamicCellCount: CGFloat =  CGFloat(columns.filter { !$0.type.fixedWidth }.count)
    //        let dynamicWidth: CGFloat = max((rect.size.width - fixedWidth) / dynamicCellCount, 0)
    //        let h = textHeight
    //        let y = (rect.size.height - h) / 2
    //        var x: CGFloat = 0
    //        for col in columns {
    //            let str = NSMutableAttributedString(attributedString: col.name)
    //            let ps = NSMutableParagraphStyle()
    //            ps.alignment = col.type.alignment
    //            str.addAttributes(
    //                [
    //                    NSAttributedStringKey.font: theme.xsmallFont,
    //                    NSAttributedStringKey.foregroundColor: theme.secondary.base,
    //                    NSAttributedStringKey.paragraphStyle: ps
    //                ],
    //                range: NSMakeRange(0, str.length))
    //            let w = col.type.fixedWidth ? col.type.width : dynamicWidth
    //            str.draw(in: CGRect(x: x + 4, y: y, width: w - 8, height: h))
    //            x += w
    //        }
    //    }
}
