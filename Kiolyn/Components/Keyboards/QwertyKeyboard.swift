//
//  QwertyKeyboard.swift
//  kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import FontAwesomeKit

class QwertyKeyboard: KLKeyboard {

    override var rowCount: Int { return 18 }
    override var columnCount: Int { return 20 }
    override var keySize: Int { return 14 }
    
    override func createReturnButton() -> KeyboardButton? {
        return KeyboardButton.create(for: FAKMaterialIcons.longArrowReturnIcon(withSize: keyboardIconSize), row: 15, column: 15, rowSpan: 3, columnSpan: 5)
    }
    
    override func createCaplockButton() -> KeyboardButton? {
        return KeyboardButton.create(for: FAKMaterialIcons.ejectAltIcon(withSize: keyboardIconSize), row: 12, column: 0, rowSpan: 3, columnSpan: 3, action: .caplock)
    }
    
    override func createButtons() -> [KeyboardButton] {
        let prev = KeyboardButton.create(for: FAKMaterialIcons.longArrowTabIcon(withSize: keyboardIconSize), row: 15, column: 0, rowSpan:3, columnSpan: 3, action: .prev)
        prev.transform = CGAffineTransform(rotationAngle: .pi)

        return [
            // Row 1
            KeyboardButton.create(for: "!", row: 0, column: 0, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "@", row: 0, column: 2, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "#", row: 0, column: 4, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "$", row: 0, column: 6, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "%", row: 0, column: 8, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: ".", row: 0, column: 10, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: ",", row: 0, column: 12, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "*", row: 0, column: 14, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "(", row: 0, column: 16, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: ")", row: 0, column: 18, rowSpan: 3, columnSpan: 2),
            // Row 2
            KeyboardButton.create(for: "0", row: 3, column: 0, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "1", row: 3, column: 2, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "2", row: 3, column: 4, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "3", row: 3, column: 6, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "4", row: 3, column: 8, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "5", row: 3, column: 10, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "6", row: 3, column: 12, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "7", row: 3, column: 14, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "8", row: 3, column: 16, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "9", row: 3, column: 18, rowSpan: 3, columnSpan: 2),
            // Row 3
            KeyboardButton.create(for: "q", row: 6, column: 0, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "w", row: 6, column: 2, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "e", row: 6, column: 4, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "r", row: 6, column: 6, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "t", row: 6, column: 8, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "y", row: 6, column: 10, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "u", row: 6, column: 12, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "i", row: 6, column: 14, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "o", row: 6, column: 16, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "p", row: 6, column: 18, rowSpan: 3, columnSpan: 2),
            // Row 4
            KeyboardButton.create(for: "a", row: 9, column: 1, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "s", row: 9, column: 3, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "d", row: 9, column: 5, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "f", row: 9, column: 7, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "g", row: 9, column: 9, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "h", row: 9, column: 11, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "j", row: 9, column: 13, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "k", row: 9, column: 15, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "l", row: 9, column: 17, rowSpan: 3, columnSpan: 2),
            // Row 5
            self.caplockButton!,
            KeyboardButton.create(for: "z", row: 12, column: 3, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "x", row: 12, column: 5, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "c", row: 12, column: 7, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "v", row: 12, column: 9, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "b", row: 12, column: 11, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "n", row: 12, column: 13, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: "m", row: 12, column: 15, rowSpan: 3, columnSpan: 2),
            KeyboardButton.create(for: FAKMaterialIcons.arrowLeftIcon(withSize: keyboardIconSize), row: 12, column: 17, rowSpan: 3, columnSpan: 3, action: .backspace),
            // Row 6
            prev,
            KeyboardButton.create(for: FAKMaterialIcons.longArrowTabIcon(withSize: keyboardIconSize), row: 15, column: 3, rowSpan:3, columnSpan: 3, action: .next),
            KeyboardButton.create(for: " ", row: 15, column: 6, rowSpan: 3, columnSpan: 9),
            self.returnButton!
        ]
    }
}
