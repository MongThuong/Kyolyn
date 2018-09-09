//
//  Double+Print.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/5/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension Double {
    /// Return currency formatted value with pad left to 10 characters.
    var asPrintingMoney: String {
        return self.asMoney.padLeft(10)
    }

    /// Formatted string for count value (no decimal, pad right to fit 3 letters)
    var asCount: String {
        return String(format:"%3d", Int(self))
    }
}


