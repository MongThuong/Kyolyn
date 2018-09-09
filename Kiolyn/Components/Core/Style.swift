//
//  Style.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/24/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material

enum Theme {
    case light
    case dark
    
    static var dialogTheme: Theme { return .light }
    static var loginTheme: Theme { return .dark }
    static var mainTheme: Theme { return .dark }
    static var menuTheme: Theme { return .light }
    static var keyboardTheme: Theme { return .light }
    
    var primary: ColorPalette.Type {
        switch self {
        case .light:
            return Material.Color.teal.self
        case .dark:
            return Material.Color.blueGrey.self
        }
    }
    
    var secondary: ColorPalette.Type {
        switch self {
        case .light:
            return Material.Color.grey.self
        case .dark:
            return Material.Color.teal.self
        }
    }
    
    var warn: ColorPalette.Type {
        return Material.Color.deepOrange.self
    }
    
    // MARK: Color
    
    var textColor: UIColor {
        switch self {
        case .light:
            return Material.Color.darkText.primary
        case .dark:
            return Material.Color.lightText.primary
        }
    }
    
    var secondaryTextColor: UIColor {
        switch self {
        case .light:
            return Material.Color.darkText.secondary
        case .dark:
            return Material.Color.lightText.secondary
        }
    }
    
    var othersTextColor: UIColor {
        switch self {
        case .light:
            return Material.Color.darkText.others
        case .dark:
            return Material.Color.lightText.others
        }
    }
    
    var dividersColor: UIColor {
        switch self {
        case .light:
            return Material.Color.darkText.dividers
        case .dark:
            return Material.Color.lightText.dividers
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .light:
            return .white
        case .dark:
            return Color(hex: 0x292929)
        }
    }
    
    var cardBackgroundColor: UIColor {
        switch self {
        case .light:
            return .white
        case .dark:
            return Material.Color.blueGrey.darken3
        }
    }
    
    // MARK: Font Typeface && Size
    
    var titleFont: UIFont {
        return RobotoFont.medium(with: 32.0)
    }
    
    var subTitleFont: UIFont {
        return RobotoFont.medium(with: 30.0)
    }
    
    var heading1Font: UIFont {
        return RobotoFont.medium(with: 24.0)
    }

    var heading2Font: UIFont {
        return RobotoFont.medium(with: 20.0)
    }
    
    var heading3Font: UIFont {
        return RobotoFont.medium(with: 18.0)
    }
    
    var normalFontSize: CGFloat { return 16.0 }
    
    var normalFont: UIFont {
        return RobotoFont.medium(with: normalFontSize)
    }
    
    func normalFont(_ scale: CGFloat) -> UIFont {
        return RobotoFont.medium(with: normalFontSize * scale)
    }
    
    var normalBoldFont: UIFont {
        return RobotoFont.bold(with: normalFontSize)
    }
    
    func normalBoldFont(_ scale: CGFloat) -> UIFont {
        return RobotoFont.bold(with: normalFontSize * scale)
    }

    // TODO: italic font
    var normalItalicFont: UIFont {
        return RobotoFont.medium(with: normalFontSize)
    }
    
    var smallFont: UIFont {
        return RobotoFont.medium(with: 14.0)
    }
    
    var smallBoldFont: UIFont {
        return RobotoFont.bold(with: 14.0)
    }
    
    var xsmallFont: UIFont {
        return RobotoFont.medium(with: 12.0)
    }
    
    var xsmallBoldFont: UIFont {
        return RobotoFont.bold(with: 12.0)
    }
    
    var titleBoldFont: UIFont {
        return RobotoFont.bold(with: 32.0)
    }
    
    var subTitleBoldFont: UIFont {
        return RobotoFont.bold(with: 30.0)
    }
    
    var heading1BoldFont: UIFont {
        return RobotoFont.bold(with: 24.0)
    }
    
    var heading2BoldFont: UIFont {
        return RobotoFont.bold(with: 20.0)
    }
    
    var heading3BoldFont: UIFont {
        return RobotoFont.bold(with: 18.0)
    }
    
    var normalInputFont: UIFont {
        return RobotoFont.bold(with: 16.0)
    }
    
    var largeInputFont: UIFont {
        return RobotoFont.bold(with: 18.0)
    }
    
    var xlargeInputFont: UIFont {
        return RobotoFont.bold(with: 20.0)
    }
    
    var xxlargeInputFont: UIFont {
        return RobotoFont.bold(with: 24.0)
    }
    
    var xxxlargeInputFont: UIFont {
        return RobotoFont.bold(with: 30.0)
    }
    
    var headerBackground: UIColor {
        return self.primary.base
    }
    
    var headerTextColor: UIColor {
        return Material.Color.lightText.primary
    }
    
    var headerSecondaryTextColor: UIColor {
        return Material.Color.lightText.secondary
    }
    
    /// Font to be used as text in dialog
    var messageBoxIconSize: CGFloat { return CGFloat(48) }
    var messageBoxTextAttributes: [NSAttributedStringKey: Any] {
        return [
            NSAttributedStringKey.foregroundColor: Theme.dialogTheme.textColor,
            NSAttributedStringKey.font: Theme.dialogTheme.heading3Font,
        ]
    }
    
    func orderItemFont(_ size: OrderItemSize) -> UIFont {
        switch size {
        case .normal: return self.normalFont
        case .big: return self.heading3Font
        case .bigger: return self.heading2Font
        }
    }
    
    func orderItemBoldFont(_ size: OrderItemSize) -> UIFont {
        switch size {
        case .normal: return self.normalBoldFont
        case .big: return self.heading3BoldFont
        case .bigger: return self.heading2BoldFont
        }
    }
    
    func orderItemSubFont(_ size: OrderItemSize) -> UIFont {
        switch size {
        case .normal: return self.smallFont
        case .big: return self.normalFont
        case .bigger: return self.heading3Font
        }
    }
    
    var guideline: CGFloat { return InterimSpacePresetToValue(preset: .interimSpace4) }
    
    var appBarHeight: CGFloat { return CGFloat(HeightPreset.large.rawValue) }
    var titleHeight: CGFloat { return CGFloat(HeightPreset.xxlarge.rawValue) }
    
    var textSmallHeight: CGFloat { return CGFloat(HeightPreset.tiny.rawValue) }
    
    var smallButtonHeight: CGFloat { return CGFloat(HeightPreset.small.rawValue) }
    var buttonHeight: CGFloat { return CGFloat(HeightPreset.default.rawValue) }
    var normalButtonHeight: CGFloat { return CGFloat(HeightPreset.normal.rawValue) }
    var mediumButtonHeight: CGFloat { return CGFloat(HeightPreset.medium.rawValue) }
    var largeButtonHeight: CGFloat { return CGFloat(HeightPreset.large.rawValue) }
    var xlargeButtonHeight: CGFloat { return CGFloat(HeightPreset.xlarge.rawValue) }
    var xxlargeButtonHeight: CGFloat { return CGFloat(HeightPreset.xxlarge.rawValue) }
    
    var smallIconButtonWidth: CGFloat { return CGFloat(HeightPreset.default.rawValue) }
    var mediumIconButtonHeight: CGFloat { return CGFloat(HeightPreset.medium.rawValue) }
    
    var navigationIconSize: CGFloat { return CGFloat(18) }
    
    var dialogToolbarHeight: CGFloat { return CGFloat(HeightPreset.large.rawValue) }
    
    var normalInputHeight: CGFloat { return CGFloat(HeightPreset.default.rawValue) }
    var mediumInputHeight: CGFloat { return CGFloat(HeightPreset.medium.rawValue) }
    var largeInputHeight: CGFloat { return CGFloat(HeightPreset.large.rawValue) }
    var xlargeInputHeight: CGFloat { return CGFloat(HeightPreset.xlarge.rawValue) }
    
    var loadingSmallSize: CGFloat { return CGFloat(HeightPreset.xsmall.rawValue) }
    var loadingNormalSize: CGFloat { return CGFloat(HeightPreset.default.rawValue) }
    var loadingLargeSize: CGFloat { return CGFloat(HeightPreset.large.rawValue) }
    
    var buttonSelectedBorderWidth: CGFloat { return 3 }
    
    var tableDashStrokeWidth: CGFloat { return 3.0 }
    var tableSelectedColor: UIColor { return UIColor(hex: 0x546E7A) }
    var tableAreaWidth: CGFloat { return 100 }
    var tableActionWidth: CGFloat { return 120 }

    var standardTableWidth: CGFloat { return 160 }
    var standardTableHeight: CGFloat { return 80 }
    
    var tablesViewSize: CGSize { return CGSize(width: 2000, height: 2000) }
    
    var billViewWidth: CGFloat { return 320 }
    var orderDetailViewWidth: CGFloat { return 340 }

    var comboBoxMinWidth: CGFloat { return 120 }
}
