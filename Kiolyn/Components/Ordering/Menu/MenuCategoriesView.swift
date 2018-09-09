//
//  MenuCategoriesController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// For displaying categories.
class MenuCategoriesView: KLMenuView {
    private let theme =  Theme.mainTheme
    let typesView = UIScrollView()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    // Need to alloc before call setup
    override func allocSettinggs() {
        super.allocSettinggs()
        
        self.viewModel = MenuCategoriesViewModel()
        self.settings = self.viewModel.settings.ordering.categories
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = theme.cardBackgroundColor
        
        let categoriesViewModel: MenuCategoriesViewModel = viewModel as! MenuCategoriesViewModel
        
        // Category types tab view
        addSubview(typesView)
        typesView.snp.makeConstraints { make in
            make.height.equalTo(theme.buttonHeight)
            make.top.width.centerX.equalToSuperview()
        }
        categoriesViewModel.types
            .asDriver()
            .drive(onNext: { types in
                self.set(categoryTypes: types)
            })
            .disposed(by: disposeBag)
        
        // Separator
        let separator = UIView()
        separator.backgroundColor = theme.dividersColor
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.centerX.equalToSuperview()
            make.top.equalTo(typesView.snp.bottom)
        }
        
        // Categories GridView
        itemsView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(theme.guideline/2)
            make.leading.equalToSuperview().offset(theme.guideline/2)
            make.bottom.trailing.equalToSuperview()
        }
        categoriesViewModel.selectedType
            .asDriver()
            .drive(onNext: { self.set(selectedType: $0) })
            .disposed(by: disposeBag)
    }
    
    private func set(selectedType: CategoryTypeViewModel?) {
        guard let (_, categories) = selectedType else {
            return
        }
        let buttons: [CategoryGridButton] = itemsView.allocate(items: categories, with: viewModel.settings.ordering.categories)
        let categoriesViewModel: MenuCategoriesViewModel = viewModel as! MenuCategoriesViewModel
        for button in buttons {
            button.disposeBag = DisposeBag()
            button.rx.tap
                .asDriver()
                .map { button.object }
                .drive(categoriesViewModel.selectedCategory)
                .disposed(by: button.disposeBag!)
            categoriesViewModel.selectedCategory
                .asDriver()
                .map { selectedCategory in selectedCategory?.id == button.object.id }
                .drive(button.rx.isSelected)
                .disposed(by: button.disposeBag!)
        }
        
        // set zoom level
        itemsView.setZoomScale(getFirstScale(), animated: false)
        itemsView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    private func set(categoryTypes types: [CategoryTypeViewModel]) {
        // Clear existing view
        for v in typesView.subviews {
            v.removeFromSuperview()
            // this implicitly dispose the button and also its dispose bag which
            // in turn will dispose the tap binding
        }        
        // Allocate new types
        var totalWidth: CGFloat = 0.0
        let categoriesViewModel: MenuCategoriesViewModel = viewModel as! MenuCategoriesViewModel
        for (name, categories) in types {
            let button = MenuTypeButton()
            button.title = name
            button.sizeToFit()
            let width: CGFloat = max(button.frame.width + theme.guideline*2, 60)
            typesView.addSubview(button)
            button.snp.makeConstraints({ make in
                make.height.top.equalToSuperview()
                make.width.equalTo(width)
                make.leading.equalTo(totalWidth)
            })
            totalWidth += width
            
            button.disposeBag = DisposeBag()
            button.rx.tap
                .map { (name, categories) }
                .bind(to: categoriesViewModel.selectedType)
                .disposed(by: button.disposeBag!)
            categoriesViewModel.selectedType
                .asDriver()
                .map { selectedType in selectedType?.0 == name }
                .drive(button.rx.isSelected)
                .disposed(by: disposeBag)
        }
        typesView.contentSize = CGSize(width: totalWidth, height: theme.buttonHeight)
    }

    func viewModel() -> MenuCategoriesViewModel {
        return self.viewModel as! MenuCategoriesViewModel
    }
    
    override func itemsInView() -> Int {
        if let categoryType:CategoryTypeViewModel = viewModel().selectedType.value {
            return categoryType.1.count
        } else {
            return 0
        }
    }
}
