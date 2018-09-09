//
//  ICSBuilder+Bitmap.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

extension ISCBBuilder {
    /// Append rasterized value of Attributed String.
    ///
    /// - Parameter string: The string to append.
    func append(bitmap str: NSAttributedString) {
        let image = str.rasterize(width: PrintPaperSize.threeInches.fvalue)
        appendBitmap(image, diffusion: false)

        #if DEBUG
        do {            
            let filePath = try image.save(toTempDirectory: "thermal_\(UUID().compressedUUIDString).png")
            d("Printed to \(filePath)")
        } catch (let err) {
            e(err)
        }
        #endif
    }

    /// Cut paper.
    func appendPaperCut() {
        appendCutPaper(SCBCutPaperAction.partialCutWithFeed)
    }

    /// For buzzing
    func appendBuzz() {
        appendSound(SCBSoundChannel.no1,  repeat : 3)
        appendSound(SCBSoundChannel.no2,  repeat : 3)
    }
}
