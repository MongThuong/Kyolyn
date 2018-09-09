//
//  Array.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/21/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

extension Array where Element: NSObject {
    
    /// Convenience method for removing an object from its array.
    ///
    /// - Parameter element: <#element description#>
    mutating func delete(_ element: Element) {
        guard let index = self.index(of: element) else { return }
        self.remove(at: index)
    }
}

extension Array {
    
    /// Convenient non empty check
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    /// Check if all element match given test.
    ///
    /// - Parameter isMatched: The test.
    /// - Returns: `true` if all is matched.
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

// MARK: - Convert to dictionary.
extension Array {
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
    /// Turn array of Key/Value into dictionary.
    ///
    /// - Returns: The dictionary.
    func dictionary<K: Hashable, V>() -> [K: V] where Element == Dictionary<K, V>.Element {
        var dictionary = [K: V]()
        for element in self {
            dictionary[element.key] = element.value
        }
        return dictionary
    }
    
    /// Group every objects by key selector.
    ///
    /// - Parameter key: the key selector.
    /// - Returns: the dictionary of key/values
    func group<U:Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

extension Sequence where Iterator.Element: Hashable {
    /// Return a unique sequence from input sequence.
    ///
    /// - Returns: unique sequence.
    func unique() -> [Iterator.Element] {
        return Array(Set(self))
    }
}

protocol OptionalType {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    var optional: Wrapped? { return self }
}

extension Sequence where Iterator.Element: OptionalType {
    func filterNil() -> [Iterator.Element.Wrapped] {
        return self.compactMap { $0.optional }
    }
}
