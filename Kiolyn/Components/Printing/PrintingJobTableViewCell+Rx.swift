//
//  PrintingJobTableViewCell+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: PrintingJobTableViewCell {    
    /// Binding for status changed.
    var status: Binder<ViewStatus> {
        return Binder(self.base) { view, status in
            view.message.text = status.message
            view.loading.isHidden = status.isNotLoading
            view.check.isHidden = status.isNotOK
            view.error.isHidden = status.isNotError
        }
    }
}

// MARK: - Mapping view status to printing message.
fileprivate extension ViewStatus {
    var message: String {
        switch self {
        case .loading: return "Printing ..."
        case .error(_): return "Printing has failed - Click to retry."
        case .ok: return "Printed successfully - Click to print again."
        default:
            return ""
        }
    }
}
