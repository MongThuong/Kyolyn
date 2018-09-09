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

class OrderingController: UIViewController {
    private let theme =  Theme.mainTheme

    let disposeBag = DisposeBag()

    /// The order detail controller.
    var detailController: OrderDetailController!
    /// The order interaction controller
    var interactionController: OrderInteractionController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = theme.backgroundColor
        
        let margin = theme.guideline/2
        
        // Order Detail
        detailController = OrderDetailController()
        addChildViewController(detailController)
        self.view.addSubview(detailController.view)
        detailController.view.snp.makeConstraints { make in
            make.width.equalTo(theme.orderDetailViewWidth)
            make.height.equalToSuperview().offset(-margin*2)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(margin)
        }
        detailController.didMove(toParentViewController: self)
        
        // Order Interaction
        interactionController = OrderInteractionController()
        addChildViewController(interactionController)
        self.view.addSubview(interactionController.view)
        interactionController.view.snp.makeConstraints { make in
            make.leading.equalTo(detailController.view.snp.trailing).offset(margin)
            make.height.equalToSuperview().offset(-margin*2)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-margin)
        }
        interactionController.didMove(toParentViewController: self)
        
        // Handle scaling
        detailController.viewModel.layoutScale.subscribe(onNext: { ratio in
            self.interactionController.layoutScale.accept(ratio)
        })
        .disposed(by: disposeBag)
    }
}
