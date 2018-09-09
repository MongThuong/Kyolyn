//
//  MainController.swift
//  kiolyn
//
//  Created by Chinh Nguyen on 3/10/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Material

/// Hold the logic of Application Bar / Navigation and Content management.
class MainController: NavigationDrawerController {
    // The single instance of MainController
    static var singleInstance = MainController()
    
    let disposeBag = DisposeBag()
    
    /// The view model to contain application wiring logic, this single view model is shared among toolbar, menu and main content view controller
    let viewModel: MainViewModel = MainViewModel()
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(
            rootViewController: MainToolbarController(UIViewController(), viewModel: viewModel),
            leftViewController: MainNavigationController(viewModel),
            rightViewController: nil
        )
    }
    
    override func prepare() {
        super.prepare()
        
        viewModel.openNavigationMenu
            .subscribe(onNext: { _ in self.openLeftView()})
            .disposed(by: disposeBag)
        viewModel.closeNavigationMenu
            .subscribe(onNext: { _ in self.closeLeftView()})
            .disposed(by: disposeBag)
        SP.authService.currentIdentity
            .asDriver()
            .filter { id in id == nil }
            .drive(onNext: { id in self.change(root: LoginController.singleInstance) })
            .disposed(by: disposeBag)
        rx.viewWillAppear
            .mapToVoid()
            .show(main: .tablesLayout)
            .disposed(by: disposeBag)
        rx.viewWillAppear
            .flatMap { _ in self.viewModel.dataService.loadActiveShift() }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
