//
//  SelectItemDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For selecting item inside dialog.
class SelectItemDVM<T: BaseModel>: DialogViewModel<T> {
    /// The items observable.
    let items = BehaviorRelay<[T]>(value: [])
    
    init(_ items: [T]? = nil, withTitle title: String? = nil) {
        super.init()
        
        if let title = title {
            dialogTitle.accept(title)
        }
        
        if let items = items {
            self.items.accept(items)
        } else {
            _ = dialogWillAppear
                .flatMap { self.loadData() }
                .bind(to: self.items)
        }
    }
    
    /// Abstract loading method, child class need to override this method to provide the data loading logic.
    ///
    /// - Returns: An array of data of the given type.
    func loadData() -> Single<[T]> {
        fatalError("Not implemented")
    }
}
