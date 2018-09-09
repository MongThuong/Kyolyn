//
//  ModifierCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// For layout the area information.
class ModifierCell: KLTableViewCell {
    private let theme =  Theme.mainTheme
    var disposeBag: DisposeBag?
    
    /// Return the selected indicator
    let selectedIndicator = UIView()
    
    override var isSelected: Bool {
        didSet {
            selectedIndicator.alpha = isSelected ? 1 : 0
        }
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = UIColor.clear
        textLabel?.font = theme.normalFont
        textLabel?.numberOfLines = 2
        textLabel?.textColor = theme.textColor
        
        selectedIndicator.backgroundColor = theme.secondary.base
        selectedIndicator.alpha = 0
        addSubview(selectedIndicator)
        selectedIndicator.snp.makeConstraints { make in
            make.height.centerY.equalToSuperview()
            make.width.equalTo(4)
        }
        
        selectedIndicator.alpha = 0
    }
}
