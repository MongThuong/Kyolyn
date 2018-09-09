//
//  MenuItemsController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/1/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// For displaing items view.
class MenuItemsView: KLMenuView {
    private let theme =  Theme.mainTheme
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override func allocSettinggs() {
        super.allocSettinggs()
        
        self.viewModel = MenuItemsViewModel()
        self.settings = self.viewModel.settings.ordering.items
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = theme.cardBackgroundColor
        
        let itemsViewModel = viewModel as! MenuItemsViewModel
        itemsView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(theme.guideline/2)
            make.bottom.trailing.equalToSuperview()
        }
        itemsViewModel.items
            .asDriver()
            .drive(onNext: { self.set(items: $0) })
            .disposed(by: disposeBag)
    }
    
    private func set(items: [Item]) {
        let buttons: [ItemGridButton] = itemsView.allocate(items: items, with: viewModel.settings.ordering.items)
        let itemsViewModel = viewModel as! MenuItemsViewModel
        for button in buttons {
            button.disposeBag = DisposeBag()
            button.rx.tap
                .asDriver()
                .map { button.object }
                .drive(itemsViewModel.selectedItem)
                .disposed(by: button.disposeBag!)
            itemsViewModel.selectedItem
                .asDriver()
                .map { item in item?.id == button.object.id }
                .drive(button.rx.isSelected)
                .disposed(by: button.disposeBag!)
        }
        
        // First scale
        itemsView.setZoomScale(getFirstScale(), animated: false)
        itemsView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func viewModel() -> MenuItemsViewModel {
        return self.viewModel as! MenuItemsViewModel
    }
    
    override func itemsInView() -> Int {
        return viewModel().items.value.count
    }
}
