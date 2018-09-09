//
//  AddNewModifierDVM.swift
//  Kiolyn
//
//  Created by Tien Pham on 10/26/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddNewModifierDVM: DialogViewModel<Modifier> {
    
    let name = BehaviorRelay<String>(value: "")
    let price = BehaviorRelay<Double>(value: 0)
    
    override var dialogResult: Modifier? {
        guard name.value.isNotEmpty else {
            return nil
        }
        let option = Option(name: name.value, price: price.value)
        return Modifier(custom: option)
    }
    
    override init() {
        super.init()
        // Set dialog title
        dialogTitle.accept("Custom Modifier")
        // Can Save Check
        name.asObservable()
            .map { $0.isNotEmpty }
            .bind(to: canSave)
            .disposed(by: disposeBag)
        save.map { _ in self.dialogResult }
            .bind(to: closeDialog)
            .disposed(by: disposeBag)
    }
}
