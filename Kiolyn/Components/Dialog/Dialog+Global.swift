//
//  Dialog+Global.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

/// Show info message.
///
/// - Parameter message: The message.
func dinfo(_ message: String) {
    _ = dmodal { MessageDVM(message, type: .info) }.subscribe()
}
/// Show error message.
///
/// - Parameter message: The message.
func derror(_ message: String) {
    _ = dmodal { MessageDVM(message, type: .error) }.subscribe()
}
/// Show error message.
///
/// - Parameter error: The `Error` object.
func derror(_ error: Error) {
    derror(error.localizedDescription)
}
/// Show confirm dialog and return single result if user choose to answer yes.
///
/// - Parameters
///     - message: The message.
///     - yesText: To be displayed as positive option.
///     - noText: To be displayed as negative option.
/// - Returns: The `Observable` of user answer.
func dconfirm(_ message: String, yesText: String = "YES", noText: String = "NO") -> Single<Bool> {
    return dmodal { MessageDVM(message, type: .confirm, yesText: yesText, noText: noText) }
        .map { $0 == .yes }
}

/// Show progress dialog for a Promise
///
/// - Parameters:
///   - message: The message to display during long calculation
///   - task: The task to perform, expecting to return a value of type T.
/// - Returns: The `Observable` of the result.
func dprogress<T>(_ message: String, task: @escaping () -> Single<T>) -> Single<T> {
    return Single.create { single in
        let vm = ProgressDVM(message)
        let dialogSingle = dmodal { vm } // Show dialog without caring about the result
        _ = task().subscribe(onSuccess: { res in
            single(.success(res))
        }, onError: { error in
            single(.error(error))
        })
        return dialogSingle.subscribe()
    }
}

/// Show message and return
///
/// - Parameters:
///   - message: The message to display during long calculation
///   - timeout: The timeout to hide dialog.
/// - Returns: The `Observable` of the result.
func dprogress(_ message: String, timeout: Int) -> Single<()> {
    return Single.create { single in
        let vm = ProgressDVM(message)
        let dialogSingle = dmodal { vm } // Show dialog without caring about the result
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
            // This will dispose the dialog subscription and close it
            single(.success(()))
        }
        return dialogSingle.subscribe()
    }
}

/// Displaying a view model as a dialog.
///
/// - Parameter vm: The view model to display.
/// - Returns: The Observable of the dialog result.
func dmodal<T, DVM: DialogViewModel<T>>(_ create: @escaping () -> DVM) -> Single<T?> {
    return Single<T?>.create { single in
        let vm = create()
        let viewModelName = NSStringFromClass(type(of: vm))
        let dialogName = "\(viewModelName[..<viewModelName.index(viewModelName.endIndex, offsetBy: -3)])Dialog"
        if let cls = NSClassFromString(dialogName) as? KLDialog<T>.Type {
             _ = cls.init(vm)
                .show()
                .subscribe(onSuccess: {
                    single(.success($0))
                }, onError: { _ in
                    single(.success(nil))
                })
        } else {
            e("\(dialogName) could not be loaded")
            single(.success(nil))
        }
        return Disposables.create {
            vm.closeDialog.onNext(nil)
        }
    }.subscribeOn(ConcurrentMainScheduler.instance)
}
