//
//  KLBar.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/14/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material

class KLBar: KLView {
    let theme: Theme
    let border = CALayer()
    let leftContainerView = UIStackView()
    let rightContainerView = UIStackView()
    let leftPadView = UIView()
    let rightPadView = UIView()

    var leftViews: [UIView] = [] {
        didSet {
            for v in leftContainerView.subviews {
                v.removeFromSuperview()
            }
            for v in leftViews {
                leftContainerView.addArrangedSubview(v)
                v.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
                v.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
            }
            leftContainerView.addArrangedSubview(leftPadView)
        }
    }

    var rightViews: [UIView] = [] {
        didSet {
            for v in rightContainerView.subviews {
                v.removeFromSuperview()
            }
            for v in rightViews.reversed() {
                rightContainerView.addArrangedSubview(v)
                v.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
                v.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
            }
            rightContainerView.addArrangedSubview(rightPadView)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let leftWidth = leftViews.reduce(0) { (w, v) -> CGFloat in
            w + v.intrinsicContentSize.width + leftContainerView.spacing
        }
        let rightWidth = rightViews.reduce(0) { (w, v) -> CGFloat in
            w + v.intrinsicContentSize.width + rightContainerView.spacing
        }
        return CGSize(width: leftWidth + rightWidth, height: theme.normalButtonHeight)
    }

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
        
        leftContainerView.axis = .horizontal
        leftContainerView.alignment = .fill
        leftContainerView.distribution = .fill
        addSubview(leftContainerView)

        rightContainerView.axis = .horizontal
        rightContainerView.alignment = .fill
        rightContainerView.distribution = .fill
        rightContainerView.semanticContentAttribute = .forceRightToLeft
        addSubview(rightContainerView)
        
        // Bottom border
        border.backgroundColor = theme.primary.darken4.cgColor
        border.opacity = 0.75
        layer.addSublayer(border)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        let pad = theme.guideline/2
        let w = frame.size.width/2
        border.frame = CGRect(x: 0, y: frame.height-1, width: frame.width, height: 1)
        leftContainerView.frame = CGRect(x: pad, y: pad, width: w - pad, height: frame.size.height - pad*2)
        rightContainerView.frame = CGRect(x: w, y: pad, width: w - pad, height: frame.size.height - pad*2)
        leftContainerView.spacing = theme.guideline
        rightContainerView.spacing = theme.guideline
    }
}
