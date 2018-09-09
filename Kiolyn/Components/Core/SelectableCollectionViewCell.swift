//
//  SelectableCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

class SelectableCollectionViewCell: Material.CollectionViewCell {
    let theme = Theme.dialogTheme
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = theme.buttonSelectedBorderWidth
                borderColor = theme.warn.base
            } else {
                layer.borderWidth = 0
                borderColor = .clear
            }
        }
    }
    
    override func prepare() {
        super.prepare()
        depthPreset = .depth5
        cornerRadiusPreset = .cornerRadius2
        clipsToBounds = true
    }
}
