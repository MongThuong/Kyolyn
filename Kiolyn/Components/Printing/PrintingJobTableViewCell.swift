//
//  File.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import FontAwesomeKit
import DRPLoadingSpinner

/// For displaying a printing job row.
class PrintingJobTableViewCell: KLTableViewCell {
    let theme = Theme.light
    var disposeBag: DisposeBag?
    
    let name = UILabel()
    let message = UILabel()
    let loading = DRPLoadingSpinner()
    let check = UILabel()
    let error = UILabel()
    
    override func prepare() {
        super.prepare()
        
        name.textColor = theme.textColor
        name.font = theme.heading2BoldFont
        addSubview(name)
        name.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline)
            make.top.equalToSuperview().offset(theme.guideline/2)
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        
        message.textColor = theme.secondaryTextColor
        message.font = theme.normalFont
        addSubview(message)
        message.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline)
            make.bottom.equalToSuperview().offset(-theme.guideline/2)
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        
        loading.colorSequence = [theme.primary.base]
        loading.lineWidth = 3
        loading.startAnimating()
        addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(theme.loadingSmallSize)
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.centerY.equalToSuperview()
        }
        
        check.textColor = theme.primary.base
        check.fakIcon = FAKFontAwesome.checkIcon(withSize: theme.smallIconButtonWidth/2)
        addSubview(check)
        check.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.centerY.equalToSuperview()
        }
        
        error.textColor = theme.warn.base
        error.fakIcon = FAKFontAwesome.exclamationTriangleIcon(withSize: theme.smallIconButtonWidth/2)
        addSubview(error)
        error.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.centerY.equalToSuperview()
        }
        
        let separator = KLSeparator(theme)
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
