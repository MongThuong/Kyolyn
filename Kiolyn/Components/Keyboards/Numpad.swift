//
//  Numpad.swift
//  kiolyn
//
//  Created by Chinh Nguyen on 2/27/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import FontAwesomeKit

class Numpad: KLKeyboard {
    
    override var rowCount: Int { return 6 }
    override var columnCount: Int { return 3 }
    
    override func createReturnButton() -> KeyboardButton? {
        return KeyboardButton.create(for: FAKMaterialIcons.longArrowReturnIcon(withSize: keyboardIconSize), row: 4, column: 2, rowSpan: 2)
    }

    override func createButtons() -> [KeyboardButton] {
        let prev = KeyboardButton.create(for: FAKMaterialIcons.longArrowTabIcon(withSize: keyboardIconSize), row: 5, column: 0, action: .prev)
        prev.transform = CGAffineTransform(rotationAngle: .pi)
        return [
            KeyboardButton.create(for: "1", row: 0, column: 0),
            KeyboardButton.create(for: "2", row: 0, column: 1),
            KeyboardButton.create(for: "3", row: 0, column: 2),
            KeyboardButton.create(for: "4", row: 1, column: 0),
            KeyboardButton.create(for: "5", row: 1, column: 1),
            KeyboardButton.create(for: "6", row: 1, column: 2),
            KeyboardButton.create(for: "7", row: 2, column: 0),
            KeyboardButton.create(for: "8", row: 2, column: 1),
            KeyboardButton.create(for: "9", row: 2, column: 2),
            KeyboardButton.create(for: "CLR", row: 3, column: 0, action: .clear),
            KeyboardButton.create(for: "0", row: 3, column: 1),
            KeyboardButton.create(for: FAKMaterialIcons.arrowLeftIcon(withSize: keyboardIconSize), row: 3, column: 2, action: .backspace),
            KeyboardButton.create(for: FAKMaterialIcons.minusIcon(withSize: keyboardIconSize), row: 4, column: 0, action: .minus(1)),
            KeyboardButton.create(for: FAKMaterialIcons.plusIcon(withSize: keyboardIconSize), row: 4, column: 1, action: .add(1)),
            prev,
            KeyboardButton.create(for: FAKMaterialIcons.longArrowTabIcon(withSize: keyboardIconSize), row: 5, column: 1, action: .next),
            self.returnButton!
        ]
    }
}
