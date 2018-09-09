//
//  Selectable.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/30/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Wrapping of selectable item.
class Selectable<T> {
    let item: T
    var isSelected = false
    init(_ item: T, selected: Bool = false) {
        self.item = item
        self.isSelected = selected
    }
}
