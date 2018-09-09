//
//  MenuItemsViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Hold the logic of loading / showing of the Ordering's Items Area
class MenuItemsViewModel: KLMenuViewModel {

    /// Publish to this to force a reloading of Items.
    let category = BehaviorRelay<Category?>(value: nil)
    /// Return all being displayed categories.
    let items = BehaviorRelay<[Item]>(value: [])
    /// Publish to enable item selected
    let selectedItem = BehaviorRelay<Item?>(value: nil)

    /// Create with service provider
    ///
    /// - Parameter provider: Service provider.
    override init() {
        super.init()
        
        category
            .filterNil()
            .flatMapLatest { category in
                self.dataService.load(items: category.id)
                    .map { items -> [Item] in
                        var items = items
                        if category.allowOpenItem {
                            items.append(category.openItem)
                        }
                        return items
                    }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: disposeBag)

        // Notify about the item selected
        selectedItem
            .asDriver()
            .filterNil()
            .drive(SP.orderManager.itemSelected)
            .disposed(by: disposeBag)
    }
}


