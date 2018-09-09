//
//  OptionGridOption.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

/// Option grid button.
class OptionGridButton: GridButton<Option> {
    private let theme =  Theme.mainTheme
    
    required init(object: Option, settings: OrderingGridSettings) {
        super.init(object: object, settings: settings)
    }
    
    override func prepare() {
        super.prepare()
        
        // BACKGROUND
        if let color = toColorInt(object.color) {
            self.backgroundColor = UIColor(hex: color)
        } else if !object.name.isEmpty {
            self.backgroundColor = object.name.color
        } else {
            self.backgroundColor = theme.secondary.base
        }
        // PRICE
        let price = UILabel()
        price.backgroundColor = UIColor(hex: 0, alpha: 0.5)
        price.text = object.price.asMoney
        price.font = theme.normalBoldFont
        price.textColor = UIColor.yellow
        price.layoutMargins = EdgeInsetsPresetToValue(preset: .horizontally2)
        self.addSubview(price)
        price.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalTo(20.0)
        }
        // NAME
        let name = UILabel()
        name.text = object.name.uppercased()
        name.font = RobotoFont.medium(with: CGFloat(settings.fontSize))
        name.textColor = theme.textColor
        name.numberOfLines = 3
        name.textAlignment = .center
        self.addSubview(name)
        name.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.centerX.equalToSuperview()
            make.top.equalTo(price.snp.bottom)
        }
    }
}
