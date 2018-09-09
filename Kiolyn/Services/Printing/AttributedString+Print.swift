//
//  AttributedString+Print.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// Constants font type
fileprivate let fontRegular = "TheSansMonoCondensed-Plain"
fileprivate let fontBold = "TheSansMonoCondensed-SemiBold"
let printingFontSizeBase: CGFloat = 24

// MARK: - Extension for rasterizing to image.
extension NSAttributedString {
    /// Create raster image from `NSAttributedString` for printing.
    ///
    /// - Parameters:
    ///   - data: The data to rasterize.
    ///   - width: The width of the printing.
    /// - Returns: The `UIImage` of the data.
    func rasterize(width: CGFloat) -> UIImage {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .truncatesLastVisibleLine]
        let dataRect = self.boundingRect(with: CGSize(width: width, height: 10000), options: options, context: nil)
        let dataSize = dataRect.size
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
            if UIScreen.main.scale == 2.0 {
                UIGraphicsBeginImageContextWithOptions(dataSize, false, 1.0)
            } else {
                UIGraphicsBeginImageContext(dataSize)
            }
        } else {
            UIGraphicsBeginImageContext(dataSize)
        }
        // Build the image
        let context = UIGraphicsGetCurrentContext()!
        UIColor.white.set()
        let rect = CGRect(x: 0, y: 0, width: dataSize.width + 1, height: dataSize.height + 1)
        context.fill(rect)
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

/// Extension NSMutableAttributedString to append string with NSAttributedString
extension NSMutableAttributedString {

    func appendX2(_ text: String) {
        self.append(text, bold: false, center: false, size: printingFontSizeBase*2)
    }
    func appendCenter(_ text: String) {
        self.append(text, bold: false, center: true)
    }
    func appendCenterX2(_ text: String) {
        self.append(text, bold: false, center: true, size: printingFontSizeBase*2)
    }
    func appendBold(_ text : String) {
        self.append(text, bold: true)
    }
    func appendBoldCenter(_ text : String) {
        self.append(text, bold: true, center: true)
    }
    func appendBoldX2(_ text : String) {
        self.append(text, bold: true, center: false, size: printingFontSizeBase*2)
    }
    func appendBoldCenterX2(_ text : String) {
        self.append(text, bold: true, center: true, size: printingFontSizeBase*2)
    }

    /// Append a string with custom style.
    ///
    /// - Parameters:
    ///   - text: The text to append.
    ///   - bold: `true` to format as bold.
    ///   - center: `true` to center aligned.
    ///   - fontSize: the size of the text.
    func append(_ text: String, bold: Bool = false, center: Bool = false, size fontSize: CGFloat = printingFontSizeBase) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 10.0
        paragraph.alignment = center ? .center : .left
        let font = UIFont(name: bold ? fontBold : fontRegular, size: fontSize)
        let attributes = [
            NSAttributedStringKey.font: font as Any,
            NSAttributedStringKey.paragraphStyle: paragraph]
        self.append(NSAttributedString(string: text, attributes: attributes))
    }
}





