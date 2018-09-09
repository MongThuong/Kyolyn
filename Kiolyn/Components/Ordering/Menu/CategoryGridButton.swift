//
//  CategoryGridButon.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

/// Category grid button.
class CategoryGridButton: GridButton<Category> {
    private let theme =  Theme.mainTheme
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderWidth = self.theme.buttonSelectedBorderWidth
                self.borderColor = self.theme.warn.base
            } else {
                self.layer.borderWidth = 0
                self.borderColor = .clear
            }
        }
    }
    
    required init(object: Category, settings: OrderingGridSettings) {
        super.init(object: object, settings: settings)
    }
    
    override func prepare() {
        super.prepare()
        
        // BACKGROUND
        if let color = toColorInt(object.color) {
            backgroundColor = UIColor(hex: color)
        } else if !object.name.isEmpty {
            backgroundColor = object.name.color
        } else {
            backgroundColor = theme.secondary.base
        }
        // TITLE
        title = object.name.uppercased()
        titleColor = theme.textColor
        titleLabel?.font = RobotoFont.medium(with: CGFloat(settings.fontSize))
        titleLabel?.numberOfLines = 3
        titleLabel?.textAlignment = .center
    }
}
