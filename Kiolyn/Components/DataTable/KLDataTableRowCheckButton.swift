//
//  KLDataTableRowCheckButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import FontAwesomeKit

/// For displaying as checked order.
class KLDataTableRowCheckButton: Material.Button {
    var theme: Theme!
    
    let check = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        depthPreset = .depth1
        shapePreset = .circle
        contentEdgeInsetsPreset = .square1
        pulseAnimation = .centerWithBacking
        backgroundColor = theme.secondary.base
        
        titleLabel?.isUserInteractionEnabled = false
        
        addSubview(check)
        check.isHidden = true
        check.textAlignment = .center
        check.isUserInteractionEnabled = false
        check.clipsToBounds = true
        check.textColor = theme.textColor
        check.set(icon: FAKFontAwesome.checkIcon(withSize: 20.0))
        check.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
            }) { _ in
                self.check.isHidden = !self.isSelected
                self.layer.transform = CATransform3DIdentity
            }
        }
    }
}
