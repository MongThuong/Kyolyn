//
//  PrintingJob.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/4/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// A single printing job.
class PrintingJob: NSObject {
    /// The printer to perform printing on.
    let printer: Printer
    /// The status of this printing job.
    let status = BehaviorRelay<ViewStatus>(value: .none)
    
    init(_ printer: Printer) {
        self.printer = printer
    }
}

