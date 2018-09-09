//
//  Dictionary.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/10/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

extension Dictionary {
    
    /// Convert dictionary to JSON string.
    ///
    /// - Returns: pretty print JSON string.
    func toJsonString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: jsonData, encoding: String.Encoding.utf8)!
        } catch {
            return "Invalid JSON"
        }
    }
    
    /// Check whether all element match given testing.
    ///
    /// - Parameter isMatched: The condition testing.
    /// - Returns: `true` if all items match given condition.
    /// - Throws: Whatever thrown inside condition.
    func all(_ isMatched: (Element) throws -> Bool) rethrows -> Bool {
        for e in self {
            if try isMatched(e) == false { return false }
        }
        return true
    }
    
    /// Check if any of the elements matches given test
    ///
    /// - Parameter isMatched: The test.
    /// - Returns: `true` if at least one element is matched.
    func any(_ isMatched: (Element) throws -> Bool) rethrows -> Bool {
        for e in self {
            if try isMatched(e) { return true }
        }
        return false
    }
}
