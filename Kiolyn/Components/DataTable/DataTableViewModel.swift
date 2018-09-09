//
//  DataTableViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

/// Base class for loading data as table with support for pagination
class DataTableViewModel<R: QueryResult<T>, T: Mappable>: BaseViewModel {
    /// The data used for binding to `KLDataTable`.
    let data = BehaviorRelay<R>(value: R())
    /// The trigger to force reloading of data.
    let reload = PublishSubject<Void>()
    /// The current page size.
    let pageSize = BehaviorRelay<UInt>(value: 10)
    /// The current page
    let page = BehaviorRelay<UInt>(value: 1)
    /// Current selected row.
    let selectedRow = BehaviorRelay<T?>(value: nil)
    /// The status of loading
    let viewStatus = BehaviorRelay<ViewStatus>(value: .none)
    /// Create with service provider
    ///
    /// - Parameter provider: Service provider.
    override init() {
        super.init()

        // Reset page to 1 on page size changed
        pageSize
            .asObservable()
            .map { _ -> UInt in 1 }
            .bind(to: page)
            .disposed(by: disposeBag)

        reload
            .filter { self.viewStatus.value.isNotLoading }
            .filter {
                // Reset the page before reloading
                if self.page.value > 1 {
                    self.page.accept(1)
                }
                return true
            }
            .flatMap { _ in self.loadData() } // TODO: fix loading 2 times
            .bind(to: data)
            .disposed(by: disposeBag)
        
        data.asDriver()
            .map { data -> T? in nil }
            .drive(selectedRow)
            .disposed(by: disposeBag)

        // Reload upon page or pageSize changed
        Observable.merge(
            pageSize.asObservable().distinctUntilChanged().mapToVoid(),
            page.asObservable().distinctUntilChanged().mapToVoid())
            .filter { self.viewStatus.value.isNotLoading }
            .flatMap { _ in self.loadData() }
            .bind(to: data)
            .disposed(by: disposeBag)
    }

    /// Main function for loading data.
    ///
    /// - Returns: `QueryResult<T>`.
    func loadData() -> Single<R> {
        return Single.just(R())
    }
}
