//
//  NameValueView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

/// Single row of order summary, including a title and a value.
class NameValueView: KLView {
    private let theme =  Theme.mainTheme
    
    let name = UILabel()
    let amount = UILabel()
    
    var font: UIFont? {
        didSet {
            let font = self.font ?? theme.smallFont
            self.name.font = font
            self.amount.font = font
        }
    }
    
    class func name(_ name: String) -> NameValueView {
        let row = NameValueView()
        row.name.text = name
        row.amount.text = "$0.00"
        return row
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: theme.textSmallHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        
        name.sizeToFit()
        var height = name.frame.size.height
        name.frame = CGRect(x: 0, y: (frame.size.height-height)/2, width: frame.width*0.55, height: height)
        
        amount.sizeToFit()
        height = amount.frame.size.height
        amount.frame = CGRect(x: frame.width*0.55, y: (frame.size.height-height)/2, width: frame.width*0.45, height: height)
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        font = theme.smallFont
        
        name.textColor = theme.secondaryTextColor
        name.layoutMargins = EdgeInsetsPresetToValue(preset: .vertically1)
        addSubview(name)
        
        amount.textColor = theme.textColor
        amount.textAlignment = .right
        amount.layoutMargins = EdgeInsetsPresetToValue(preset: .vertically1)
        addSubview(amount)
    }
}
