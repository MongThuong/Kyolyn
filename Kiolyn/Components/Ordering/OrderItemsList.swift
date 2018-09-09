//
//  OrderItemsList.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// For displayin of OrderItems
class OrderItemsList: KLTableView {
    
    var normalFont: UIFont?
    var boldFont: UIFont?
    var subFont: UIFont?
    
    var size: OrderItemSize = OrderItemSize.normal {
        didSet {
            normalFont = theme.orderItemFont(size)
            boldFont = theme.orderItemBoldFont(size)
            subFont = theme.orderItemSubFont(size)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override init(_ theme: Theme = Theme.mainTheme) {
        super.init(theme)
        alwaysBounceVertical = true
        _ = rx.setDelegate(self)
    }
    
    func scrollToBottom() {
        let numItems = self.numberOfRows(inSection: 0)
        if numItems > 0 {
            self.scrollToRow(at: IndexPath(item: numItems - 1, section: 0), at: .bottom, animated: false)
        }
    }
}

extension OrderItemsList: UITableViewDelegate {
    /// Dynamically calculating height of cells.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        do {
            let normalFont = self.normalFont ?? theme.normalFont
            let subFont = self.subFont ?? theme.smallFont
            let item: OrderItem = try self.rx.model(at: indexPath)
            let (_, _, _, height) = getHeight(forItemDetailCell: item, nfont: normalFont, sfont: subFont, nameW: tableView.frame.width - 204)
            return max(theme.largeButtonHeight, height)
        } catch {
            return theme.largeButtonHeight
        }
    }
}
