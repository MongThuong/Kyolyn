//
//  KLSeparator.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/19/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material


/// For drawing a separator
class KLLine: KLView {
    var theme: Theme!
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        backgroundColor = theme.primary.darken4
        alpha = 0.75
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
}

/// For separating items.
class KLSeparator: KLView {
    var theme: Theme!
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        alpha = 0.75
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        // Transaparent background
        UIColor.clear.setFill()
        path.fill()
        // Dash border
        theme.primary.darken2.setStroke()
        path.lineWidth = 2
        let dashPattern : [CGFloat] = [4, 4]
        path.setLineDash(dashPattern, count: 2, phase: 0)
        path.stroke()
        // Draw the main content
        super.draw(rect)
    }
}
