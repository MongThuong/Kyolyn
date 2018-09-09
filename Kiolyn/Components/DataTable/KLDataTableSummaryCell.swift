//
//  KLDataTableWithSummary.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import SnapKit

/// Column definition
struct KLDataTableSummaryCell {
    var type: KLDataTableColumnType
    var value: (_ obj: QuerySummary) -> String
}
