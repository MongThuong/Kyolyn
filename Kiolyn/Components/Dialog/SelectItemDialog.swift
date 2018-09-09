//
//  SelectItemDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Generic based class for all item selection dialog.
class SelectItemDialog<T: BaseModel> : KLDialog<T> {
    var cellType: AnyClass { return SelectItemTableViewCell<T>.self }
    var cellHeight: CGFloat { return theme.normalButtonHeight }
    
    /// The main table view.
    let tableView = KLTableView()
    /// The correspondence view model
    private let viewModel: SelectItemDVM<T>
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<T>) {
        self.viewModel = vm as! SelectItemDVM<T>
        super.init(vm)
    }
    
    /// Build the table layout
    ///
    /// - Returns: The dialog content view.
    override func makeDialogContentView() -> UIView? {
        tableView.rowHeight = CGFloat(cellHeight)
        tableView.register(cellType, forCellReuseIdentifier: "Cell")
        return tableView
    }
    
    /// Prepare the binding.
    override func prepare() {
        super.prepare()
        // Bind to table
        viewModel.items
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SelectItemTableViewCell<T>
                cell.item = element
                return cell
            }
            .disposed(by: disposeBag)
        // Save the result and close dialog upon selecting of an item
        tableView.rx.modelSelected(T.self)
            .bind(to: viewModel.closeDialog)
            .disposed(by: disposeBag)
    }
}
