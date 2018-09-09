//
//  OrderingController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

class CustomersController: CommonDataTableController<Customer> {

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override init(_ viewModel: DataTableViewModel<QueryResult<Customer>, Customer> = CustomersViewModel()) {
        super.init(viewModel)
        columns.accept([
            KLDataTableColumn<Customer>(name: "NAME", type: .name, value: { $0.name }),
            KLDataTableColumn<Customer>(name: "ADDRESS", type: .address, value: { $0.address }),
            KLDataTableColumn<Customer>(name: "EMAIL", type: .email, value: { $0.email }),
            KLDataTableColumn<Customer>(name: "PHONE", type: .phone, value: { $0.mobilephone.formattedPhone }) ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel()
        titleLabel.font = theme.normalFont
        titleLabel.textColor = theme.textColor
        titleLabel.text = "CUSTOMERS"
        bar.leftViews = [titleLabel]
        bar.rightViews = [refresh]
    }
}
