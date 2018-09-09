//
//  Navigation+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Convenient change view method
extension ObservableType where E == MainContentViewType {
    func show() -> Disposable {
        return self
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: SP.navigation.mainView)
    }
}

extension ObservableType where E == OrderingInteractionViewType {
    func show() -> Disposable {
        return self
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: SP.navigation.orderingInteractionView)
    }
}

extension ObservableType {
    func show(main type: MainContentViewType) -> Disposable {
        return self
            .observeOn(MainScheduler.asyncInstance)
            .map { _ in type }.show()
    }
    func show(ordering type: OrderingInteractionViewType) -> Disposable {
        return self
            .observeOn(MainScheduler.asyncInstance)
            .map { _ in type }.show()
    }
}
