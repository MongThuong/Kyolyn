//
//  MenuOptionsViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Hold the logic of loading / showing of the Ordering's Options Area
class MenuOptionsViewModel: KLMenuViewModel {
    /// Publish to this to force a reloading of options.
    let modifier = BehaviorRelay<Modifier?>(value: nil)
    /// Publish to enable option selected
    var selectedOption = BehaviorRelay<Option?>(value: nil)

    override init() {
        super.init()

        selectedOption
            .asDriver()
            .map { (self.modifier.value, $0) }
            .filter { (mod, opt) in mod != nil && opt != nil }
            .map { (mod, opt) in (mod!, opt!) }
            .drive(orderManager.optionSelected)
            .disposed(by: disposeBag)
    }
}

