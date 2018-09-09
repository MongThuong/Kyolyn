//
//  MenuTypeButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import Material

/// The action button on the right column.
class MenuTypeButton: FlatButton {
    let theme =  Theme.mainTheme
    var disposeBag: DisposeBag? = nil
    let selectedIndicator = UIView()
    
    override var isSelected: Bool {
        didSet {
            selectedIndicator.alpha = isSelected ? 1 : 0
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        
        titleColor = theme.textColor
        titleLabel?.font = theme.normalFont
        
        selectedIndicator.backgroundColor = theme.secondary.base
        selectedIndicator.alpha = 0
        addSubview(selectedIndicator)
        selectedIndicator.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(4)
        }
    }
}
