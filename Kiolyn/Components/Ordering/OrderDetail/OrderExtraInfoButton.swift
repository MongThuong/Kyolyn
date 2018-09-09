//
//  OrderExtraInfoButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For displaying extra information
class OrderExtraInfoButton: KLFlatButton {
    let summary = OrderItemsSummary()
    let status = UILabel()
    let line = KLLine()
    
    override var intrinsicContentSize: CGSize {
        let summarySize = summary.intrinsicContentSize
        let statusSize = status.intrinsicContentSize
        return CGSize(width: summarySize.width + statusSize.width + theme.guideline, height: summarySize.height + theme.guideline)
    }
    
    override func prepare() {
        super.prepare()
        status.isHidden = true
        status.textAlignment = .center
        addSubview(status)
        status.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(theme.smallIconButtonWidth)
        }
        summary.isUserInteractionEnabled = false
        addSubview(summary)
        summary.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalTo(status.snp.leading)
        }
        addSubview(line)
        line.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
        }
    }
}
