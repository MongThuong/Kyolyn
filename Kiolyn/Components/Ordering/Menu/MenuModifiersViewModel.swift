//
//  MenuModifiersViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/27/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For displaying of global modifiers inside ordering area.
class MenuModifiersViewModel: BaseViewModel {
    /// Publish to this to force a reloading of the global modifiers
    let reload = PublishSubject<Void>()
    /// Publish to set the selected modifier.
    let selectedModifier = BehaviorRelay<Modifier?>(value: nil)
    /// Publish to set the open modifier.
    let openModifier = PublishSubject<Void>()
    /// Return all available ares
    let modifiers = BehaviorRelay<[Modifier]>(value: [])

    /// Create with service provider
    ///
    /// - Parameter provider: Service provider.
    override init() {
        super.init()
        reload
            .flatMap { self.dataService.loadGlobalModifiers() }
            .asDriver(onErrorJustReturn: [])
            .drive(modifiers)
            .disposed(by: disposeBag)
        openModifier
            .modal { AddNewModifierDVM() }
            .map { mod in (mod, mod.options.first!) }
            .bind(to: orderManager.optionSelected)
            .disposed(by: disposeBag)
   }
}

