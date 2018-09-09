//
//  KLListView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 7/18/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Material

class KLTableView: Material.TableView {
    var theme: Theme!
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        super.init(frame: .zero, style: .plain)
        self.theme = theme
        backgroundColor = .clear
        separatorStyle = .none
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
        layoutMargins = UIEdgeInsets.zero
        separatorColor = .clear
        allowsSelection = true
        alwaysBounceVertical = false
        isScrollEnabled = true
        rowHeight = CGFloat(theme.buttonHeight)
    }
}
