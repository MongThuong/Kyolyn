//
//  EditCustomerDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 10/19/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EditCustomerDialog: KLDialog<Order> {
    private var viewModel: EditCustomerDVM
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Order>) {
        guard let vm = vm as? EditCustomerDVM else {
            fatalError("Expecting EditCustomerDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    let editCustomer = EditCustomerView()
    
    override var dialogWidth: CGFloat { return 540 }
    override var dialogHeight: CGFloat { return 600 }
    
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [
            (editCustomer.name, self.textKeyboard),
            (editCustomer.phone, self.textKeyboard),
            (editCustomer.email, self.textKeyboard),
            (editCustomer.address, self.textKeyboard)
        ]
    }
    
    override func makeDialogContentView() -> UIView? {
        let view = UIView()
        view.addSubview(editCustomer)
        return view
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        editCustomer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline)
        }
    }
    
    override func prepare() {
        super.prepare()
        editCustomer.name.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: viewModel.customerName)
            .disposed(by: disposeBag)
        editCustomer.phone.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: viewModel.customerPhone)
            .disposed(by: disposeBag)
        editCustomer.email.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: viewModel.customerEmail)
            .disposed(by: disposeBag)
        editCustomer.address.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .bind(to: viewModel.customerAddress)
            .disposed(by: disposeBag)
        editCustomer.clear.rx.tap
            .map { nil }
            .bind(to: viewModel.customer)
            .disposed(by: disposeBag)
        
        // Disable everything if the order item cannot be edited
        guard viewModel.order.notDelivered else {
            dialogContentView?.isUserInteractionEnabled = false
            dialogContentView?.alpha = 0.5
            return
        }
        _ = viewModel.dialogDidAppear
            .subscribe(onNext: { _ in
                _ = self.editCustomer.name.becomeFirstResponder()
            })
        
        viewModel.customer
            .asDriver()
            .drive(editCustomer.rx.customer)
            .disposed(by: disposeBag)
        viewModel.customers
            .asDriver()
            .map { $0.isEmpty }
            .drive(editCustomer.rx.isEmpty)
            .disposed(by: disposeBag)
        viewModel.customers
            .asDriver()
            .drive(editCustomer.result.rx.items) { (tableView, row, customer) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomerTableViewCell
                cell.customer = customer
                return cell
            }
            .disposed(by: disposeBag)
        editCustomer.result.rx.modelSelected(Customer.self)
            .bind(to: viewModel.customer)
            .disposed(by: disposeBag)
    }
}


