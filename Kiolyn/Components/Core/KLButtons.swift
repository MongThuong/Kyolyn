//
//  KLButtons.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/11/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material

protocol KLThemeButton {
    var theme: Theme { get }
}

class KLRaisedButton: RaisedButton, KLThemeButton {
    var theme: Theme

    required init?(coder aDecoder: NSCoder) {
        self.theme = .mainTheme
        super.init(frame: .zero)
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    open override func prepare() {
        super.prepare()
        contentEdgeInsetsPreset = .wideRectangle2
        titleLabel?.font = theme.normalFont
        titleColor = theme.textColor
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.25
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: max(theme.normalButtonHeight, size.width), height: max(theme.normalButtonHeight, size.height))
    }
}

/// Primary button using in menu screen.
class KLPrimaryRaisedButton: KLRaisedButton {
    open override func prepare() {
        super.prepare()
        backgroundColor = theme.secondary.base
        titleColor = theme.textColor
    }
}

/// For displaying on bar
class KLBarPrimaryRaisedButton: KLPrimaryRaisedButton {
    override func prepare() {
        super.prepare()
        contentEdgeInsetsPreset = .wideRectangle1
        titleLabel?.font = theme.smallFont
    }
}

/// Primary button using in menu screen.
class KLWarnRaisedButton: KLRaisedButton {
    open override func prepare() {
        super.prepare()
        backgroundColor = theme.warn.base
        titleColor = theme.textColor
    }
}

/// For displaying on bar
class KLBarWarnRaisedButton: KLWarnRaisedButton {
    override func prepare() {
        super.prepare()
        contentEdgeInsetsPreset = .wideRectangle1
        titleLabel?.font = theme.smallFont
    }
}

/// Flat button for displaying with icon
class KLFlatButton: FlatButton, KLThemeButton {
    var theme: Theme
    
    required init?(coder aDecoder: NSCoder) {
        self.theme = .mainTheme
        super.init(frame: .zero)
    }
    
    init(theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    open override func prepare() {
        super.prepare()
        contentEdgeInsetsPreset = .wideRectangle2
        titleLabel?.font = theme.normalFont
        titleColor = theme.textColor
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.25
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: max(theme.normalButtonHeight, size.width), height: max(theme.normalButtonHeight, size.height))
    }
}

/// For displaying of flat button on bar.
class KLBarFlatButton: KLFlatButton {
    override func prepare() {
        super.prepare()
        contentEdgeInsetsPreset = .wideRectangle1
        titleLabel?.font = theme.smallFont
    }
}

/// For displaying as chip
class KLChip : KLFlatButton {
    
    override func prepare() {
        super.prepare()
        titleLabel?.font = theme.xsmallFont
        titleColor = theme.textColor
        layer.borderWidth = 1
        borderColor = .clear
    }
    
    override var isSelected: Bool {
        didSet {
            borderColor = isSelected ? theme.secondary.lighten1 : .clear
        }
    }
}


/// Primary button using in menu screen.
class KLPrimaryFlatButton: KLFlatButton { }

/// Primary button using in menu screen.
class KLWarnFlatButton: KLFlatButton {
    var textColor: UIColor {
        return theme.warn.base
    }
}
