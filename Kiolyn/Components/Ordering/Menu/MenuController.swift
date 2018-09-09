//
//  MenuController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// Control the display of Categories/Items/Global Modifiers/Global Modifiers Options
class MenuController: UIViewController {
    let theme = Theme.mainTheme
    let disposeBag = DisposeBag()
    
    let categoriesView = MenuCategoriesView()
    let modifiersView = MenuModifiersView()
    let itemsView = MenuItemsView()
    let optionsView = MenuOptionsView()
    
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
        
        // CATEGORIES
        view.addSubview(categoriesView)
        categoriesView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
        }
        rx.viewWillAppear
            .mapToVoid()
            .bind(to: categoriesView.viewModel().reload)
            .disposed(by: disposeBag)
        categoriesView.viewModel().selectedCategory
            .asDriver()
            .filterNil()
            .drive(onNext: { category in
                self.itemsView.isHidden = false
                self.itemsView.viewModel().category.accept(category)
                self.optionsView.isHidden = true
                self.modifiersView.viewModel.selectedModifier.accept(nil)
            })
            .disposed(by: disposeBag)

        // MODIFIERS
        view.addSubview(modifiersView)
        modifiersView.snp.makeConstraints { make in
            make.width.equalTo(104)
            make.top.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp.top).offset(-self.theme.guideline)
        }
        rx.viewWillAppear
            .mapToVoid()
            .bind(to: modifiersView.viewModel.reload)
            .disposed(by: disposeBag)
        modifiersView.viewModel.selectedModifier
            .asDriver()
            .filterNil()
            .drive(onNext: { modifier in
                self.itemsView.isHidden = true
                self.categoriesView.viewModel().selectedCategory.accept(nil)
                self.optionsView.isHidden = false
                self.optionsView.viewModel().modifier.accept(modifier)
            })
            .disposed(by: disposeBag)

        // ITEMS
        view.addSubview(itemsView)
        itemsView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp.top).offset(-self.theme.guideline/2)
            make.trailing.equalTo(modifiersView.snp.leading).offset(-self.theme.guideline/2)
        }

        // OPTIONS
        view.addSubview(optionsView)
        optionsView.snp.makeConstraints { make in
            make.edges.equalTo(itemsView)
        }
        
        // Handle scaling
        layoutScale.subscribe(onNext: { ratio in
            self.itemsView.layoutScale.accept(ratio)
            self.categoriesView.layoutScale.accept(ratio)
            self.optionsView.layoutScale.accept(ratio)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
    }
}
