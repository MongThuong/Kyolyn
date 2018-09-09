//
//  EditOrder.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/7/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// For editing an Order.
class EditOrderDialog: KLDialog<Order> {
    
    private let viewModel: EditOrderDVM
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Order>) {
        guard let vm = vm as? EditOrderDVM else {
            fatalError("Expecting EditOrderDVM")
        }
        viewModel = vm
        super.init(vm)
    }
    
    let guests = KLUIntClearField()
    let customer = KLView()
    let customerLabel = UILabel()
    let editCustomer = EditCustomerView()
    
    override var dialogWidth: CGFloat { return 540 }
    override var dialogHeight: CGFloat { return 600 }
    
    /// Return the keyboard mapping
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [
            (guests, self.numpad),
            (editCustomer.name, self.textKeyboard),
            (editCustomer.phone, self.textKeyboard),
            (editCustomer.email, self.textKeyboard),
            (editCustomer.address, self.textKeyboard)
        ]
    }
    
    /// Build dialog content here.
    override func makeDialogContentView() -> UIView? {
        let view = UIView()
        
        // Guests
        guests.placeholder = "# Guests"
        guests.font = theme.xxlargeInputFont
        guests.maxValue = 99
        guests.placeholderActiveScale = 0.45
        guests.placeholderVerticalOffset = 52.0
        guests.textAlignment = .center
        view.addSubview(guests)
        
        // Customer Area
        customerLabel.font = theme.heading2Font
        customerLabel.text = "CUSTOMER"
        customerLabel.textColor = theme.primary.base
        customer.addSubview(customerLabel)
        customer.addSubview(editCustomer)
        view.addSubview(customer)
        
        return view
    }

    override func prepare() {
        super.prepare()
        // GUESTS
        guests.shouldClearInFirstTime = viewModel.shouldClearInFirstTime
        guests.value = viewModel.guests.value
        guests.rx.value
            .asDriver()
            .drive(viewModel.guests)
            .disposed(by: disposeBag)
        // CUSTOMER
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
        guard viewModel.order.isNotClosed else {
            dialogContentView?.isUserInteractionEnabled = false
            dialogContentView?.alpha = 0.5
            return
        }
        
        // Hide everything at first, wait until area is available
        self.guests.isHidden = true
        self.customer.isHidden = true
        
        // This should happen only once
        _ = viewModel.area
            .asDriver()
            .drive(onNext: { self.set(area: $0) })

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
    
    private func set(area: Area?) {
        guard let area = area else { return }
        // Display correspondence views
        guests.isHidden = !area.noOfGuestPrompt
        customer.isHidden = !area.customerInfoPrompt
        
        let gl = theme.guideline
        
        if !guests.isHidden {
            guests.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(gl)
                make.trailing.equalToSuperview().offset(-gl)
                make.height.equalTo(theme.largeInputHeight)
            }
        }
        
        if !customer.isHidden {
            customer.snp.makeConstraints { make in
                make.bottom.trailing.equalToSuperview().offset(-gl)
                make.leading.equalToSuperview().offset(gl)
                if guests.isHidden {
                    make.top.equalToSuperview().offset(gl*2)
                } else {
                    make.top.equalTo(guests.snp.bottom).offset(gl*2)
                }
            }
            customerLabel.snp.makeConstraints { make in
                make.top.trailing.leading.equalToSuperview()
                make.height.equalTo(theme.normalInputHeight)
            }
            editCustomer.snp.makeConstraints { make in
                make.top.equalTo(customerLabel.snp.bottom).offset(gl)
                make.bottom.trailing.leading.equalToSuperview()
            }
        }
        
        // Focus to right field
        if area.noOfGuestPrompt {
            _ = guests.becomeFirstResponder()
            if viewModel.shouldClearInFirstTime {
                guests.selectedTextRange = guests.textRange(from: guests.beginningOfDocument, to: guests.endOfDocument)
                viewModel.canSave.accept(viewModel.guests.value > 0)
            }
        } else if area.customerInfoPrompt {
            _ = editCustomer.name.becomeFirstResponder()
        }
    }
}
