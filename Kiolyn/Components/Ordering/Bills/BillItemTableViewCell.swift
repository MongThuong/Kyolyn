//
//  BillItemTableViewCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import RxSwift
import RxCocoa

/// For displaying item cell.
class BillItemTableViewCell: Material.TableViewCell {
    var theme = Theme.mainTheme
    var disposeBag: DisposeBag?
    
    let detailView = OrderItemDetailView()
    
    var orderItem: OrderItem? {
        didSet {
            guard let orderItem = self.orderItem else { return }
            detailView.orderItem = orderItem
        }
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        addSubview(detailView)
        detailView.snp.makeConstraints { make in
            make.height.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-theme.guideline)
        }
        
        let separator = KLSeparator()
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.width.bottom.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
