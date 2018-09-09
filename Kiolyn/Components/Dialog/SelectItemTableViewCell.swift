//
//  SelectItemDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Represent an item cell.
class SelectItemTableViewCell<T: BaseModel>: KLTableViewCell {
    var disposeBag: DisposeBag? = nil
    // These cells mostly be used inside dialog
    let theme = Theme.light
    
    var item: T? {
        didSet {
            self.textLabel?.text = item?.name
        }
    }
    
    override func prepare() {
        super.prepare()
        
        let separator = KLSeparator(theme)
        separator.layer.zPosition = 1000
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.bottom.centerX.equalToSuperview()
        }
    }
}
