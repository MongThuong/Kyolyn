//
//  EditCustomerDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 10/19/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EditCustomerDVM: DialogViewModel<Order> {
    let order: Order
    
    let customer = BehaviorRelay<Customer?>(value: nil)
    let customerName = BehaviorRelay<String>(value: "")
    let customerPhone = BehaviorRelay<String>(value: "")
    let customerEmail = BehaviorRelay<String>(value: "")
    let customerAddress = BehaviorRelay<String>(value: "")
    
    let customers = BehaviorRelay<[Customer]>(value: [])
    
    init(_ order: Order) {
        self.order = order
        super.init()
        
        dialogTitle.accept("Edit Customer #\(order.orderNo)")
        
        customer
            .asDriver()
            .drive(onNext: { customer in
                self.customerName.accept(customer?.name ?? "")
                self.customerPhone.accept(customer?.mobilephone ?? "")
                self.customerEmail.accept(customer?.email ?? "")
                self.customerAddress.accept(customer?.address ?? "")
            })
            .disposed(by: disposeBag)
        
        dialogDidAppear
            .flatMap { _ -> Single<Customer?> in self.dataService.load(order.customer) }
            .bind(to: customer)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                customerName.asObservable(),
                customerPhone.asObservable(),
                customerEmail.asObservable(),
                customerAddress.asObservable())
            .skip(1)
            // Don't search the same value over again
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2 && lhs.3 == rhs.3
            }
            .flatMap { query -> Single<[Customer]> in
                self.dataService.load(customers: query)
            }
            .asDriver(onErrorJustReturn: [])
            .drive(customers)
            .disposed(by: disposeBag)
    
        save
            .flatMap { self.save() }
            .filterNil()
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
        
        // Can save by default
        canSave.accept(true)
    }
    
    func save() -> Single<Order?> {
        let (name, phone, email, address) = (
            self.customerName.value,
            self.customerPhone.value,
            self.customerEmail.value,
            self.customerAddress.value
        )
        // Customer is selected, and user might have changed the input values which we have to update
        let customer = self.customer.value ?? Customer(inStore: store)
        customer.name = name
        customer.mobilephone = phone.replacingOccurrences(of: "-", with: "")
        customer.email = email
        customer.address = address
        return dataService.save(customer) // Save the customer first
            .map { customer in self.order.set(customer: customer) } // Then assign to order
    }
}
