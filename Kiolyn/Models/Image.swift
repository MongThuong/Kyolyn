//
//  Image.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Contain information about `Item`'s image.
class Image: BaseModel {
    /// Return MIME type of this image.
    var mime = ""
    /// Return MIME type of this image.
    var size: Double = 0
    /// Return file name of this image, use this value relatively to the `cdnRootUrl` to get the final URL of the image.
    var file = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        mime <- map["mime"]
        size <- map["size"]
        file <- map["file"]
    }
}
