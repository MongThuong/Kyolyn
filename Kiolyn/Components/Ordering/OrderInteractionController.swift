//
//  OrderInteractionController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// The ordering interaction area.
class OrderInteractionController: UIViewController {
    let disposeBag = DisposeBag()
    
    // Settings Area
    let layoutScale = BehaviorRelay<CGFloat>(value: 1.0)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let childControllers: [OrderingInteractionViewType: UIViewController] = [
            .menu: MenuController(),
            .orders: OrdersController(),
            .bills: BillsController()]
        
        // setup child view controller
        for childController in childControllers.values {
            super.addChildViewController(childController)
            self.view.addSubview(childController.view)
            childController.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            childController.didMove(toParentViewController: self)
            childController.view.isHidden = true
        }
        
        // Update view on ordering interaction view changed
        SP.navigation.orderingInteractionView
            .asDriver()
            .distinctUntilChanged()
            .drive(onNext: { type in
                for (childType, childController) in childControllers {
                    childController.view.isHidden = type != childType
                }
            })
            .disposed(by: disposeBag)
        
        // Handle scaling
        layoutScale.bind(to: (childControllers[.menu] as! MenuController).layoutScale)
        .disposed(by: disposeBag)
    }
}
