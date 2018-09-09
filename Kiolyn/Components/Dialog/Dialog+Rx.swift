//
//  Dialog+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    /// Displaying a view model as a dialog.
    ///
    /// - Parameter vm: The view model to display.
    /// - Returns: The Observable of the dialog result.
    func modal<T, DVM: DialogViewModel<T>>(_ create: @escaping (E) -> DVM) -> Observable<T> {
        return self
            .flatMap { e in dmodal { create(e) } }
            .filterNil()
    }
    
    /// Displaying a confirm dialog.
    ///
    /// - Parameter vm: The view model to display.
    /// - Returns: The Observable of the dialog result.
    func confirm(_ message: String, yesText: String = "YES", noText: String = "NO") -> Observable<MessageDR> {
        return self
            .modal { _ in MessageDVM(message, type: .confirm, yesText: yesText, noText: noText) }
            .filter { yes in yes == .yes }
    }

    /// Perform a long task with progress dialog.
    ///
    /// - Parameters:
    ///   - message: The message to display during long calculation
    ///   - task: The task to perform, expecting to return a value of type T.
    /// - Returns: The `Observable` of the result.
    func progress<T>(_ message: String, task: @escaping (E) -> Single<T>) -> Observable<T> {
        return self.flatMap { e -> Single<T> in
            Single.create { single in
                let vm = ProgressDVM(message)
                let dialogSingle = dmodal { vm } // Show dialog without caring about the result
                DispatchQueue.main.async {
                    _ = task(e).subscribe(onSuccess: { res in
                        vm.closeDialog.onNext(())
                        single(.success(res))
                    }, onError: { error in
                        vm.closeDialog.onNext(())
                        single(.error(error))
                    })
                }
                return dialogSingle.subscribe()
            }
        }
    }

    /// Show progress with timeout.
    ///
    /// - Parameters:
    ///   - message: the message to display as progres
    ///   - timeout: the dialog timeout in seconds.
    /// - Returns: The `Observable` of the input.
    func progress(_ message: String, timeout: Int) -> Observable<E> {
        return self
            .flatMap { e -> Single<E> in
                dprogress(message, timeout: timeout).map { _ in e }
            }
            .asObservable()
    }
}

// MARK: - Display message
extension ObservableType where E == (MessageDT, String) {
    /// Show an information dialog
    ///
    /// - Parameter message: The message to be shown.
    /// - Returns: The Observable of the dialog result.
    func showMessage() -> Disposable {
        return self
            .flatMap { (type, message) in dmodal { MessageDVM(message, type: type) } }
            .subscribe()
    }
}

extension ObservableType where E == String {    
    /// Convenient chaining method.
    ///
    /// - Returns: the disposable of the action
    func showInfo() -> Disposable {
        return self
            .flatMap { message in dmodal { MessageDVM(message) } }
            .subscribe()
    }
}

