//
//  KLTableViewCell+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITableViewCell {
    /// Bindable sink for `isUserInteractionEnabled` property.
    public var isSelected: Binder<Bool> {
        return Binder(self.base) { view, isSelected in
            view.isSelected = isSelected
        }
    }
    
    /// Bindable sink for `label text color` property.
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { view, textColor in
            view.textLabel?.textColor = textColor
        }
    }
}
