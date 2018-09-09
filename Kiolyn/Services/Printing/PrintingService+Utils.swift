//
//  PrintingService+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/11/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

extension PrintingService {
    /// If there is default printer, send the open cash drawer command to it.
    /// Otherwise just return in peace.
    ///
    /// - Returns: The single of the result.
    func openCashDrawer() {
        guard let printer = SP.authService.defaultPrinter else {
            return
        }
        _ = SP.printingService.open(cashDrawer: printer).subscribe()
    }
}
