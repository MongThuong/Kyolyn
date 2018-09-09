//
//  NavigationItem.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import FontAwesomeKit
import RxSwift

/// Common navigation item
protocol NavigationItem {
}

/// Separator navigation item
class MenuNavigationItemSeparator: NavigationItem {
}

/// Description about a single navigation item.
class MenuNavigationItem: NavigationItem {
    /// Name of this item.
    var name: String
    /// The image to be used for displaying.
    var icon: FAKIcon
    /// True if this item can be interacted.
    var isEnabled: Bool = true
    /// For publishing the selected event.
    let onSelected = PublishSubject<Void>()
    init(_ name: String, withIcon icon: FAKIcon)  {
        self.name = name
        self.icon = icon
    }
}

