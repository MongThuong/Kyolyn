//
//  MenuOptionsView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/2/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// For displaying options view.
class MenuOptionsView: KLMenuView {
    private let theme =  Theme.mainTheme
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override func allocSettinggs() {
        super.allocSettinggs()
        
        self.viewModel = MenuOptionsViewModel()
        self.settings = self.viewModel.settings.ordering.options
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = theme.cardBackgroundColor
        
        // OPTIONS
        let optionsViewModel = viewModel as! MenuOptionsViewModel
        itemsView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(theme.guideline/2)
            make.bottom.trailing.equalToSuperview()
        }
        optionsViewModel.modifier
            .asDriver()
            .filterNil()
            .map { $0.options }
            .drive(onNext: { self.set(options: $0) })
            .disposed(by: disposeBag)
    }
    
    private func set(options: [Option]) {
        let buttons: [OptionGridButton] = itemsView.allocate(items: options, with: viewModel.settings.ordering.options)
        let optionsViewModel = viewModel as! MenuOptionsViewModel
        for button in buttons {
            button.disposeBag = DisposeBag()
            button.rx.tap
                .asDriver()
                .map { button.object }
                .drive(optionsViewModel.selectedOption)
                .disposed(by: button.disposeBag!)
            optionsViewModel.selectedOption
                .asDriver()
                .map { option in option?.id == button.object.id }
                .drive(button.rx.isSelected)
                .disposed(by: button.disposeBag!)
        }
        
        itemsView.setZoomScale(getFirstScale(), animated: false)
        itemsView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func viewModel() -> MenuOptionsViewModel {
        return self.viewModel as! MenuOptionsViewModel
    }
    
    override func itemsInView() -> Int {
        if let modifier:Modifier = viewModel().modifier.value {
            return modifier.options.count
        } else {
            return 0
        }
    }
 }
