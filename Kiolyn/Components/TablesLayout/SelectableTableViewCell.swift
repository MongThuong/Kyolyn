//
//  SelectableCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Table view cell with selected indicator
class SelectableTableViewCell: KLTableViewCell {
    let theme =  Theme.mainTheme
    var disposeBag: DisposeBag? = nil

    let selectedIndicator = UIView()

    override var isSelected: Bool {
        didSet {
            self.selectedIndicator.alpha = self.isSelected ? 1 : 0
        }
    }

    override func prepare() {
        super.prepare()
        backgroundColor = UIColor.clear
        textLabel?.font = theme.normalFont
        textLabel?.numberOfLines = 2
        textLabel?.textColor = theme.textColor
        /// For fix #KIO-711 https://willbe.atlassian.net/browse/KIO-711
        textLabel?.lineBreakMode = .byTruncatingMiddle
        selectedIndicator.backgroundColor = theme.secondary.base
        selectedIndicator.alpha = 0
        addSubview(selectedIndicator)
        selectedIndicator.snp.makeConstraints { make in
            make.height.centerY.equalToSuperview()
            make.width.equalTo(3)
        }
    }
}
