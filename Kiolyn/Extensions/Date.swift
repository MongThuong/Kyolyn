//
//  Date.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/23/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

extension Date {
    
    /// Short firm to string with format.
    ///
    /// - Parameter dateFormat: The format.
    /// - Returns: The date formatted with given format.
    func toString(_ dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
