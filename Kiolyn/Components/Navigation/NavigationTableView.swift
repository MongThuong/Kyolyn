//
//  NavigationTable.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Material
import RxSwift
import RxCocoa

/// For controlling the navigation items.
class NavigationTableView: Material.TableView {
    let theme =  Theme.menuTheme
    let disposeBag = DisposeBag()
    let items = BehaviorRelay<[NavigationItem]>(value: [])
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(frame: .zero, style: .plain)
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = theme.backgroundColor
        layoutMargins = UIEdgeInsets.zero
        allowsSelection = true
        tableHeaderView = nil
        isScrollEnabled = false
        rowHeight = theme.mediumButtonHeight
        delegate = self
        register(KLTableViewCell.self, forCellReuseIdentifier: "Item")
        register(KLTableViewCell.self, forCellReuseIdentifier: "Separator")
        self.rx.modelSelected(MenuNavigationItem.self)
            .subscribe(onNext: { item in
                item.onSelected.onNext(())
            })
            .disposed(by: disposeBag)
        items
            .asDriver()
            .drive(onNext: { _ in
                self.invalidateIntrinsicContentSize()
            })
            .disposed(by: disposeBag)
        items
            .asDriver()
            .drive(rx.items) { (tableView, row, element) in
                guard let item = element as? MenuNavigationItem else {
                    let cell = self.dequeueReusableCell(withIdentifier: "Separator") as! KLTableViewCell
                    cell.isUserInteractionEnabled = false
                    cell.backgroundColor = self.theme.primary.lighten4
                    cell.alpha = 1
                    return cell
                }
                
                let cell = self.dequeueReusableCell(withIdentifier: "Item") as! KLTableViewCell
                cell.textLabel?.font = self.theme.normalFont
                cell.textLabel?.textColor = self.theme.primary.base
                cell.textLabel?.set(icon: item.icon, withText: item.name)
                if item.isEnabled {
                    cell.isUserInteractionEnabled = true
                    cell.alpha = 1
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.alpha = 0.25
                }                
                return cell
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Adjust row height
extension NavigationTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model: NavigationItem = try! tableView.rx.model(at: indexPath)
        if model is MenuNavigationItemSeparator {
            return 1
        }
        return tableView.rowHeight
    }
}
