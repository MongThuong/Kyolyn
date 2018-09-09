//
//  CashKeyboard.swift
//  kiolyn
//
//  Created by Chinh Nguyen on 3/1/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import Material
import FontAwesomeKit

class CashKeyboard: KLKeyboard {
    
    var openCashDrawerKey = KeyboardButton.create(for: "OPEN CASH DRAWER", row: 6, column: 0, columnSpan: 4)
    
    override var rowCount: Int { return 7 }
    override var columnCount: Int { return 4 }
    
    override func createReturnButton() -> KeyboardButton? {
        return KeyboardButton.create(for: FAKMaterialIcons.longArrowReturnIcon(withSize: keyboardIconSize), row: 4, column: 3, rowSpan: 2)
    }
 
    override func createButtons() -> [KeyboardButton] {
        openCashDrawerKey.titleColor = Theme.dialogTheme.warn.base
        let prev = KeyboardButton.create(for: FAKMaterialIcons.longArrowTabIcon(withSize: keyboardIconSize), row: 5, column: 1, action: .prev)
        prev.transform = CGAffineTransform(rotationAngle: .pi)
        return [
            KeyboardButton.create(for: "$100", row: 0, column: 0, action: .add(100)),
            KeyboardButton.create(for: "1", row: 0, column: 1),
            KeyboardButton.create(for: "2", row: 0, column: 2),
            KeyboardButton.create(for: "3", row: 0, column: 3),
            KeyboardButton.create(for: "$50", row: 1, column: 0, action: .add(50)),
            KeyboardButton.create(for: "4", row: 1, column: 1),
            KeyboardButton.create(for: "5", row: 1, column: 2),
            KeyboardButton.create(for: "6", row: 1, column: 3),
            KeyboardButton.create(for: "$20", row: 2, column: 0, action: .add(20)),
            KeyboardButton.create(for: "7", row: 2, column: 1),
            KeyboardButton.create(for: "8", row: 2, column: 2),
            KeyboardButton.create(for: "9", row: 2, column: 3),
            KeyboardButton.create(for: "$10", row: 3, column: 0, action: .add(10)),
            KeyboardButton.create(for: "CLR", row: 3, column: 1, action: .clear),
            KeyboardButton.create(for: "0", row: 3, column: 2),
            KeyboardButton.create(for: FAKMaterialIcons.arrowLeftIcon(withSize: keyboardIconSize), row: 3, column: 3, action: .backspace),
            KeyboardButton.create(for: "$5", row: 4, column: 0, action: .add(5)),
            KeyboardButton.create(for: FAKMaterialIcons.minusIcon(withSize: keyboardIconSize), row: 4, column: 1, action: .minus(1)),
            KeyboardButton.create(for: FAKMaterialIcons.plusIcon(withSize: keyboardIconSize), row: 4, column: 2, action: .add(1)),
            KeyboardButton.create(for: "$2", row: 5, column: 0, action: .add(2)),
            prev,
            KeyboardButton.create(for: FAKMaterialIcons.longArrowTabIcon(withSize: keyboardIconSize), row: 5, column: 2, action: .next),
            self.returnButton!,
            self.openCashDrawerKey
        ]
    }
}
