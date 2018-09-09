//
//  OrderInfoButton.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For displaying as butotn
class OrderInfoButton: KLFlatButton {
    let orderInfo = OrderInfo()
    let sep = KLLine()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: theme.orderDetailViewWidth, height: theme.normalButtonHeight)
    }
    
    override func prepare() {
        super.prepare()
        addSubview(orderInfo)
        orderInfo.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline/2)
        }
        addSubview(sep)
        sep.snp.makeConstraints { make in
            make.bottom.width.centerX.equalToSuperview()
        }
    }
}
