//
//  OrderItemCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import Material
import FontAwesomeKit

/// For displaying item cell.
class OrderItemCell: Material.TableViewCell {
    
    var theme = Theme.mainTheme
    var disposeBag: DisposeBag?
    
    let imageButton = OrderItemImageButton()
    let removeButton = KLFlatButton()
    let statusIcon = UILabel()
    let detailView = OrderItemDetailView()
    
    var orderItem: OrderItem? {
        didSet {
            guard let orderItem = self.orderItem else { return }
            detailView.orderItem = orderItem
            imageButton.orderItem = orderItem
            removeButton.isHidden = orderItem.isNotNew
            statusIcon.isHidden = orderItem.isNew
            if orderItem.isVoided {
                statusIcon.textColor = theme.warn.base
                isUserInteractionEnabled = false
                for v in subviews {
                    v.alpha = 0.75
                }
            } else {
                statusIcon.textColor = theme.secondary.base
                isUserInteractionEnabled = true
                for v in subviews {
                    v.alpha = 1
                }
            }
            switch orderItem.status {
            case .submitted:
                statusIcon.fakIcon = FAKFontAwesome.printIcon(withSize: 24.0)
            case .checked:
                statusIcon.fakIcon = FAKFontAwesome.checkIcon(withSize: 24.0)
            case .paid:
                statusIcon.fakIcon = FAKFontAwesome.dollarIcon(withSize: 24.0)
            case .voided:
                statusIcon.fakIcon = FAKFontAwesome.banIcon(withSize: 24.0)
            case .new:
                statusIcon.fakIcon = FAKFontAwesome.fileIcon(withSize: 24.0)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageButton.isSelected = isSelected
        }
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        addSubview(imageButton)
        imageButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline/2)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(theme.smallIconButtonWidth)
        }
        
        removeButton.fakIcon = FAKFontAwesome.timesIcon(withSize: 24.0)
        addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.width.equalTo(theme.smallIconButtonWidth)
            make.height.equalToSuperview().offset(-theme.guideline)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        statusIcon.textAlignment = .center
        statusIcon.isHidden = true
        addSubview(statusIcon)
        statusIcon.snp.makeConstraints { make in
            make.edges.equalTo(removeButton)
        }
        
        addSubview(detailView)
        detailView.snp.makeConstraints { make in
            make.leading.equalTo(imageButton.snp.trailing)
            make.trailing.equalTo(removeButton.snp.leading)
            make.height.centerY.equalToSuperview()
        }
        
        let separator = KLSeparator()
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.width.bottom.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
