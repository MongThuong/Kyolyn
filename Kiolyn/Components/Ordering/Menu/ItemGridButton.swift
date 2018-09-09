//
//  ItemGridButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit
import AlamofireImage

/// Item grid button.
class ItemGridButton: GridButton<Item> {
    private let theme =  Theme.mainTheme
    
    required init(object: Item, settings: OrderingGridSettings) {
        super.init(object: object, settings: settings)
    }
    
    override func prepare() {
        
        let item = object
        
        if item.isOpenItem {
            super.prepare()
            backgroundColor = theme.secondary.base
            
            let name = UILabel()
            name.fakIcon = FAKFontAwesome.plusIcon(withSize: 28.0)
            name.textColor = theme.textColor
            name.textAlignment = .center
            addSubview(name)
            name.snp.makeConstraints { make in
                make.centerY.centerX.equalToSuperview()
            }
        } else if item.hasImage {
            backgroundColor = item.name.color
            // IMAGE
            let image = UIImageView()
            image.backgroundColor = item.name.color
            image.contentMode = .scaleAspectFill
            if let url = item.image?.url {
                image.af_setImage(withURL: url)
            }
            addSubview(image)
            image.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            // PRICE
            let price = UILabel()
            price.backgroundColor = UIColor.init(hex: 0, alpha: 0.5)
            price.text = item.price.asMoney
            price.font = theme.normalBoldFont
            price.textColor = UIColor.yellow
            price.layoutMargins = EdgeInsetsPresetToValue(preset: .horizontally2)
            addSubview(price)
            price.snp.makeConstraints { make in
                make.top.right.equalToSuperview()
                make.height.equalTo(20.0)
            }
            // NAME
            let name = UILabel()
            name.backgroundColor = UIColor.init(hex: 0, alpha: 0.5)
            name.text = item.name.uppercased()
            name.font = theme.normalFont
            name.textColor = theme.textColor
            name.numberOfLines = 3
            name.textAlignment = .center
            addSubview(name)
            name.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.bottom.centerX.equalToSuperview()
            }
            // Full image will hide the pulse animation, thus move the prepare to bottom
            // to preserve the pulse animation
            super.prepare()
        } else {
            super.prepare()
            // BACKGROUND
            if let color = toColorInt(item.color) {
                backgroundColor = UIColor(hex: color)
            } else if item.name.isNotEmpty {
                backgroundColor = item.name.color
            } else {
                backgroundColor = theme.secondary.base
            }
            // PRICE
            let price = UILabel()
            price.backgroundColor = UIColor.init(hex: 0, alpha: 0.5)
            price.text = item.price.asMoney
            price.font = theme.normalBoldFont
            price.textColor = UIColor.yellow
            price.layoutMargins = EdgeInsetsPresetToValue(preset: .horizontally2)
            addSubview(price)
            price.snp.makeConstraints { make in
                make.top.right.equalToSuperview()
                make.height.equalTo(20.0)
            }
            // NAME
            let name = UILabel()
            name.text = item.name.uppercased()
            name.font = RobotoFont.medium(with: CGFloat(settings.fontSize))
            name.textColor = theme.textColor
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
}
