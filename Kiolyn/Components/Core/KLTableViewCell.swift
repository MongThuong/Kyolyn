//
//  KLTableViewCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/21/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material

class KLTableViewCell : Material.TableViewCell {
    /// Custom layout settings
    override open func prepare() {
        super.prepare()
        // Most of the time the cell take its parent background color
        backgroundColor = .clear
        heightPreset = .medium
    }
}
