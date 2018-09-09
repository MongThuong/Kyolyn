//
//  OptionCollectionViewCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

class OptionCollectionViewCell: SelectableCollectionViewCell {
    let price = UILabel()
    let name = UILabel()
    
    var option: Option? = nil {
        didSet {
            guard let option = self.option else { return }
            if let color = Int(option.color) {
                backgroundColor = UIColor(hex: color)
            } else if option.name.isNotEmpty {
                backgroundColor = option.name.color
            } else {
                backgroundColor = self.theme.primary.base
            }
            price.text = option.price.asMoney
            name.text = option.name.uppercased()
            layoutIfNeeded()
        }
    }
    
    override func prepare() {
        super.prepare()
        // PRICE
        price.backgroundColor = UIColor.init(hex: 0, alpha: 0.5)
        price.font = theme.normalBoldFont
        price.textColor = UIColor.yellow
        price.layoutMargins = EdgeInsetsPresetToValue(preset: .horizontally2)
        addSubview(price)
        price.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalTo(20.0)
        }
        // NAME
        name.font = theme.normalFont
        name.textColor = theme.headerTextColor
        name.numberOfLines = 3
        name.textAlignment = .center
        addSubview(name)
        name.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.centerX.equalToSuperview()
            make.top.equalTo(price.snp.bottom)
        }
    }
}
