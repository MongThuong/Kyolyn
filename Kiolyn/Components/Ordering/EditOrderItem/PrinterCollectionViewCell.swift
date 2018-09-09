//
//  PrinterCollectionViewCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material

class PrinterCollectionViewCell: SelectableCollectionViewCell {
    let name = UILabel()
    
    var printer: Printer? = nil {
        didSet {
            guard let printer = self.printer else { return }
            if printer.name.isNotEmpty {
                backgroundColor = printer.name.color
            } else {
                backgroundColor = self.theme.primary.base
            }
            name.text = printer.name.uppercased()
            layoutIfNeeded()
        }
    }
    
    override func prepare() {
        super.prepare()
        // NAME
        name.font = theme.normalFont
        name.textColor = theme.headerTextColor
        name.numberOfLines = 3
        name.textAlignment = .center
        addSubview(name)
        name.snp.makeConstraints { make in
            make.centerY.centerX.width.equalToSuperview()
        }
    }
}
