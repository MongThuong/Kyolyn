//
//  UUID.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension UUID {
    
    /// Compressed form of the UUID
    /// http://spinningtheweb.blogspot.fi/2014/08/shortening-uuid-guid-in-swift.html
    var compressedUUIDString: String {
        guard let tempUUID = NSUUID(uuidString: uuidString) else {
            return ""
        }
        var tempUUIDBytes: UInt8 = 0
        tempUUID.getBytes(&tempUUIDBytes)
        let data = Data(bytes: &tempUUIDBytes, count: 16)
        let base64 = data.base64EncodedString(options: NSData.Base64EncodingOptions())
        return base64.replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "/", with: "")
    }
}
