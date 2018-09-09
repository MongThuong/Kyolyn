//
//  KLMenuViewModel.swift
//  Kiolyn
//
//  Created by Anh Tai LE on 17/08/2018.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class KLMenuViewModel: BaseViewModel {
    
    let layoutScale = BehaviorRelay<CGFloat>(value: 1.0)

    override init() {
        super.init()
    }
}
