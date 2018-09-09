//
//  EditCustomerView+Rx.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/1/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: EditCustomerView {
    /// Bindable sink for `isUserInteractionEnabled` property.
    var customer: Binder<Customer?> {
        return Binder(self.base) { view, customer in
            view.name.text = customer?.name
            view.phone.text = customer?.mobilephone.formattedPhone
            view.email.text = customer?.email
            view.address.text = customer?.address
        }
    }
    
    var isEmpty: Binder<Bool> {
        return Binder(self.base) { view, isEmpty in
            view.emptyResult.isHidden = !isEmpty
            view.result.isHidden = isEmpty
        }
    }
}
