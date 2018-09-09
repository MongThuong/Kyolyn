//
//  CategoryTypeViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias CategoryTypeViewModel = (String, [Category])

/// Hold the logic of loading / showing of the Ordering's Categories Area
class MenuCategoriesViewModel: KLMenuViewModel {
    
    /// Publish to this to force a reloading of the whole data set including Areas/Tables/Orders
    var reload = PublishSubject<Void>()
    /// Return all available category types.
    let types = BehaviorRelay<[CategoryTypeViewModel]>(value: [])
    /// Publish to select a category type
    let selectedType = BehaviorRelay<CategoryTypeViewModel?>(value: nil)
    /// Publish to enable category selected
    let selectedCategory = BehaviorRelay<Category?>(value: nil)
    
    override init() {
        super.init()
        
        reload
            .flatMapLatest { _ -> Single<[Category]> in self.dataService.loadAll() }
            .map { categories -> [CategoryTypeViewModel] in
                // Get Category Types (Beverage, Dinner, Breakfast, etc.)
                let settingTypes = self.settings.categoryTypes.map { $0.uppercased() }
                // Make sure the just added categories won't be missed out
                let newTypes = categories
                    .flatMap { cat in cat.categoryTypes }
                    .filter { catType in !settingTypes.contains(catType) }
                var types = settingTypes + newTypes
                
                // create array non exist
                var uniqueTypes: [String] = []
                for cat in types {
                    if uniqueTypes.contains(cat) == false {
                        uniqueTypes.append(cat)
                    }
                }
                types = uniqueTypes
                return types
                    .map { catType in (catType, categories.filter { cat in
                        cat.categoryTypes.contains(catType)
                    }) }
                    .filter { (_, cats) in cats.isNotEmpty }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(types)
            .disposed(by: disposeBag)
        
        // Select the first category type upon reloaded
        types.map { types in types.first }.bind(to: selectedType).disposed(by: disposeBag)
        
        // Select the first category when category type is changed
        selectedType
            .asDriver()
            .map { selectedType in selectedType?.1.first }
            .drive(selectedCategory)
            .disposed(by: disposeBag)
    }
}
