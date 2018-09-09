//
//  DialogViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias DVM = DialogViewModel

/// Base dialog view model with return result.
class DialogViewModel<T>: BaseViewModel {
    /// For closing dialog with Cancelled as result.
    let closeDialog = PublishSubject<T?>()
    /// Handle save action.
    let save = PublishSubject<Void>()
    /// Publish to enable saving
    let canSave = BehaviorRelay<Bool>(value: false)
    /// Subscribe to perform did appear loading
    let dialogWillAppear = PublishSubject<Void>()
    /// Subscribe to perform did appear loading
    let dialogDidAppear = PublishSubject<Void>()
    /// The dialog title.
    let dialogTitle = BehaviorRelay<String>(value: "Willbe.vn")

    /// The dialog result that would be used if user click on close dialog button.
    var dialogResult: T? {
        return nil
    }

    var isClosed = false

    override init() {
        super.init()
        closeDialog
            .subscribe(onNext: { _ in self.isClosed = true })
            .disposed(by: disposeBag)
        // Close dialog upon singing out
        SP.authService.currentIdentity
            .filter { $0 == nil }
            .map { _ -> T? in nil }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}

