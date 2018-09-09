//
//  AdjustTipTextField.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import DRPLoadingSpinner

/// For adjusting tip on Transaction screen, keeping it here because we don't have to generalize too much.
class AdjustTipField: KLCashField {
    let wrapper = UIView()
    let loading = DRPLoadingSpinner()
    let status = UILabel()
    var adjusting = false
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override init(_ theme: Theme = .light, placeholder: String = "") {
        super.init(theme, placeholder: placeholder)
        
        addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline/2)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
        }
        
        loading.colorSequence = [.white]
        loading.isHidden = true
        wrapper.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        status.isHidden = true
        wrapper.addSubview(status)
        status.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
