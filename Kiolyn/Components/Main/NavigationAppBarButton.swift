//
//  NavigationAppBarButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/23/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

/// For displaying user information and show/hide navigation view.
class NavigationAppBarButton: FlatButton {
    private let theme =  Theme.mainTheme
    
    let abbreviation = UILabel()
    let name = UILabel()
    let shiftInfo = UILabel()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 160, height: theme.appBarHeight - theme.guideline)
    }
    
    /// We don't want optimization here
    override func sizeToFit() {
        return
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        let h = frame.size.height
        let w = frame.size.width
        let gl = theme.guideline
        let ars = theme.buttonHeight
        abbreviation.frame = CGRect(x: gl/2, y: (h - ars) / 2, width: ars, height: ars)
        let arr = abbreviation.frame.origin.x + abbreviation.frame.size.width
        let nx = arr + gl
        
        name.sizeToFit()
        let nh = name.frame.size.height
        name.frame = CGRect(x: nx, y: h/2 - nh, width: w - nx - gl/2, height: nh)
        
        shiftInfo.sizeToFit()
        let sh = shiftInfo.frame.size.height
        shiftInfo.frame = CGRect(x: nx, y: h/2, width: w - nx - gl/2, height: sh)
    }
    
    override func prepare() {
        super.prepare()
        
        abbreviation.layer.cornerRadius = 22
        abbreviation.layer.masksToBounds = true
        abbreviation.textColor = theme.textColor
        abbreviation.textAlignment = .center
        abbreviation.font = theme.heading2BoldFont
        abbreviation.backgroundColor = theme.secondary.base
        addSubview(abbreviation)
        
        name.font = theme.normalFont
        name.textColor = theme.textColor
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.75
        addSubview(name)
        
        shiftInfo.font = theme.xsmallFont
        shiftInfo.textColor = theme.textColor
        shiftInfo.alpha = 0.75
        addSubview(shiftInfo)
    }
}
