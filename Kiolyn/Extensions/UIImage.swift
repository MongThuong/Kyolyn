//
//  UIImage.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension UIImage {
    
    /// Save the current image to temp directory under given name.
    ///
    /// - Parameter file: the file name.
    /// - Throws: throws if the png image could not be created.
    func save(toTempDirectory file: String) throws -> String{
        return try save(to: NSTemporaryDirectory().appending(file))
    }
    
    /// Save the current image to the given file path.
    ///
    /// - Parameter filePath: the file path.
    /// - Throws: throws if the png image could not be created.
    func save(to filePath: String) throws -> String {
        guard let fileURL = URL(string: "file://\(filePath)"), let png = UIImagePNGRepresentation(self) else {
            return ""
        }
        try png.write(to: fileURL)
        return filePath
    }
}
