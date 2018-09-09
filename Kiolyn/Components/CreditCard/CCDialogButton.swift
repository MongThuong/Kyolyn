//
//  CCDialogButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

class CCDialogButton: KLFlatButton {
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: max(88, size.width), height: max(theme.buttonHeight, size.height))
    }
    
    override func prepare() {
        super.prepare()
        titleLabel?.font = theme.normalFont
        titleColor = theme.primary.base
    }
}
