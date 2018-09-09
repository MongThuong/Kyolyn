//
//  String.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

extension String {
    
    /// Convenient non empty check
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    /// Support `[...]` syntax to get substring from a string.
    ///
    /// - Parameter r: `Int` range.
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return String(self[startIndex...endIndex])
        }
    }
    
    
    /// MAC with `:` formatted, use to display to end user.
    var asMac: String {
        // Accept only 12 character length
        guard self.count == 12 else {
            return self
        }
        return "\(self[0...1]):\(self[2...3]):\(self[4...5]):\(self[6...7]):\(self[8...9]):\(self[10...11])".uppercased()
    }
    
    /// Remove `:` from a display mac string.
    var rawMac: String {
        return self.replacingOccurrences(of: ":", with: "")
    }
    
    /// Format a flat mac address to user friendly mac address.
    ///
    /// - Parameter delim: The deliminiter character, default as `:`.
    /// - Returns: Nicely formatted MAC address with `:` as deliminiter by default.
    func asFormattedMacAddress(_ delim: Character = ":") -> String {
        guard self.count == 12 else {
            return ""
        }
        return "\(self[0...1])\(delim)\(self[2...3])\(delim)\(self[4...5])\(delim)\(self[6...7])\(delim)\(self[8...9])\(delim)\(self[10...11])"
    }
    
    /// Get object id from document id. Document ID is constructed by <object type>_<object id>.
    ///
    /// - Parameter docType: The type/prefix of document ID.
    /// - Returns: Object ID.
    func idFromDocID(_ docType: String) -> String {
        return self[docType.count+1...self.count-1]
    }
    
    /// Unique way to hash - this must be uniqe among platform.
    var hash: Int {
        var h: Int = 0
        for i in self.unicodeScalars {
            let ch = Int(i.value)
            h = ch + (h<<5).addingReportingOverflow(-h).partialValue
            h = h & h
        }
        return h;
    }
    
    /// Convert a string to color code using string's hashcode.
    var color: UIColor {
        let hash = self.hash
        let r = CGFloat((hash & 0xFF0000) >> 16) / 0xFF
        let g = CGFloat((hash & 0x00FF00) >> 8) / 0xFF
        let b = CGFloat(hash & 0x0000FF) / 0xFF
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    
    /// Convert to hex string color code using string's hashcode value.
    var hexColor: String {
        let hash = self.hash
        let r = CGFloat((hash & 0xFF0000) >> 16) / 0xFF
        let g = CGFloat((hash & 0x00FF00) >> 8) / 0xFF
        let b = CGFloat(hash & 0x0000FF) / 0xFF
        let ir = (Int)(r*255)<<16
        let ig = (Int)(g*255)<<8
        let ib = (Int)(b*255)
        let rgb = ir | ig | ib
        return String(format: "#%06x", rgb)
    }
    
    
    /// return the first 2 characters of the first 2 words in uppercase
    var abbreviation: String {
        guard self.isNotEmpty else { return "" }
        // Split for words
        let words = self.split(separator: " ")
        // Build abbreviation from the first 2 characters
        var abbreviation = ""
        if words.count > 0 && words[0].count > 0 { abbreviation += "\(words[0].first!)" }
        if words.count > 1 && words[1].count > 0 { abbreviation += "\(words[1].first!)" }
        return abbreviation
    }
    
    /// Format as phone number
    var formattedPhone: String {
        return self.replacingOccurrences(of: "-", with: "").apply(mask: "###-###-####")
    }
    
    /// ###-###-####
    ///
    /// - Parameter mask: Masked value.
    func apply(mask: String) -> String {
        guard self.isNotEmpty else { return self }
        var output = ""
        var index = self.startIndex
        for m in mask {
            guard m == "#" else {
                output.append(m)
                continue
            }
            guard index < self.endIndex else {
                continue
            }
            output.append(self[index])
            index = self.index(index, offsetBy: 1)
        }
        return output
    }
    
    // For fixing #KIO-679 https://willbe.atlassian.net/browse/KIO-679
    func formattedPhoneNumber() -> String {
        let cleanPhoneNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "###-###-####"
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask {
            if index == cleanPhoneNumber.endIndex {
                break
            }
            if ch == "#" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    /// Return the left string with given length.
    ///
    /// - Parameter length: The length to take.
    /// - Returns: The left string with given length.
    func left(_ length: Int) -> String {
        if self.count > length {
            return "\(self[..<self.index(self.startIndex, offsetBy: length)])"
        } else {
            return self
        }
    }
    
    /// Return the remaining string at given index.
    ///
    /// - Parameter index: The start index.
    /// - Returns: The sub string started with given index.
    func right(from index: Int) -> String {
        return "\(self[self.index(self.startIndex, offsetBy: index)...])"
    }
    
    /// Pad right with space/dot to desired length.
    ///
    /// - Parameters:
    ///   - length: The expected length.
    ///   - char: The character to pad, default to space.
    /// - Returns: Right padded string with expected length.
    func padRight(_ length: Int, char: String = " ") -> String {
        return self.padding(toLength: length, withPad: char, startingAt: 0)
    }
    
    /// Pad left with space to desired length.
    ///
    /// - Parameter length: The expected length.
    /// - Returns: Left padded string with expected length.
    func padLeft(_ length: Int) -> String {
        let charCount = self.count
        if charCount < length {
            return String(repeatElement(" ", count: length - charCount)) + self
        } else {
            return "\(self[index(self.startIndex, offsetBy: charCount - length)...])"
        }
    }
    
    func exact(_ length: Int) -> String {
        return self.left(length).padRight(length)
    }
    
    /// Get the last `length` substring.
    func suffix(_ length: Int) -> String {
        return "\(self[self.index(self.endIndex, offsetBy: -length)...])"
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
}
