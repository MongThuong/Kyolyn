//
//  ModifierCollectionTitleView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

class ModifierCollectionTitleView: UICollectionReusableView {
    let theme = Theme.dialogTheme
    var titleLabel = UILabel()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.textColor = theme.primary.base
        titleLabel.font = theme.heading3Font
        addSubview(titleLabel)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

