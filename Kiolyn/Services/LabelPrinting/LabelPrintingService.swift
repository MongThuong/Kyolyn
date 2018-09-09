//
//  LabelPrintingService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/24/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

protocol LabelPrintingService {
    /// Print `OrderItem`s.
    ///
    /// - Parameters:
    ///   - items: The `Item`s to print.
    ///   - order: The `Order` that the orders belong to.
    ///   - type: The type of printing.
    ///   - printer: The `Printer` to print to
    /// - Returns: `Promise` of the printing result.
    func print(items: [[OrderItem]], ofOrder order: Order, withType type: PrintItemsType, toPrinter printer: Printer) -> Single<Void>
}
