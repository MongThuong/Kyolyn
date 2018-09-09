//
//  Double.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/16/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

extension Decimal {
    /// Calculate the rounded value in Money type with default of 2 digits after the decimal point.
    ///
    /// - Parameter digits: The number of digits afer decimal point.
    /// - Returns: A money rounded value.
    func roundM(_ digits: Int = 2) -> Decimal {
        let adjustment = pow(10, digits)
        return (self * adjustment) / adjustment
    }    
}

extension Double {
    
    /// Calculate the rounded value in Money type with default of 2 digits after the decimal point.
    ///
    /// - Parameter digits: The number of digits afer decimal point.
    /// - Returns: A money rounded value.
    func roundM(_ digits: Double = 2) -> Double {
        let adjustment = pow(10, digits)
        return (self * adjustment).rounded() / adjustment
    }
    
    
    /// Return currency formatted value.
    var asMoney: String {
        if self >= 0 {
            return String(format: "$%.02f", self)
        } else {
            return "(\(String(format: "$%.02f", -self)))"
        }
    }
    
    /// Return currency formatted value.
    var asRoundedMoney: String {
        if self >= 0 {
            return String(format: "$%.0f", self)
        } else {
            return "(\(String(format: "$%.0f", -self)))"
        }
    }
    
    /// Back in the time, quantity allow fractional, but from P.7, no fractional is allow, thus we need to remove the trailing 0s
    var asQuantity: String {
        return String(format: "%.0f", self)
    }
    
    /// Return percentage formatted value.
    var asPercentage: String {
        let p = self*100
        let diff = abs(p - p.rounded()) * 100
        if (diff.rounded() >= 1) {
            // if there are percentage with decimal places, show it
            return String(format: "%.02f%%", p)
        } else {
            // ... otherwise just show the rounded
            return String(format: "%.0f%%", p)
        }
    }
    
    
    
    func format(_ format: String) -> String {
        return String(format: format, self)
    }
}
