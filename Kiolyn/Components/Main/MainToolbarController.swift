//
//  MainToolbarController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// Main application toolbar controller.
class MainToolbarController: ToolbarController {
    let theme =  Theme.mainTheme
    let disposeBag = DisposeBag()
    
    let showMenuButton = AppBarButton("MENU")
    let showOrdersButton = AppBarButton("ORDERS")
    let showTablesButton = AppBarButton("AREAS")
    let logoutButton = AppBarButton("LOGOUT")
    let navButton = NavigationAppBarButton()
    
    /// The view model to contain application wiring logic
    let viewModel: MainViewModel
    
    /// Keep all sub view controllers
    var cachedControllers: [MainContentViewType: UIViewController] = [:]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    init(_ mainViewController: UIViewController, viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(rootViewController: mainViewController)
    }
    
    override func prepare() {
        super.prepare()
        motionTransitionType = .none
        
        // No status bar
        isStatusBarHidden = true
        toolbar.backgroundColor = Color(hex: 0x212121)
        toolbar.depthPreset = .depth2
        toolbar.heightPreset = .large
        
        // Storename
        toolbar.titleLabel.font = theme.heading1Font
        toolbar.titleLabel.textColor = theme.textColor
        
        // Timeout
        toolbar.detailLabel.font = theme.xsmallBoldFont
        toolbar.detailLabel.textColor = theme.warn.base
        toolbar.detailLabel.text = ""
        
        // Assign to toolbar
        toolbar.rightViews = [showMenuButton, showOrdersButton, showTablesButton]
        toolbar.leftViews = [navButton, logoutButton]
        
        // Load data
        SP.dataService
            .activeShift
            .asDriver()
            .map { shift in
                if let shift = shift {
                    return "Shift \(shift.index)"
                } else {
                    return "No Shift"
                }
            }
            .drive(navButton.shiftInfo.rx.text)
            .disposed(by: disposeBag)
        navButton.rx.tap
            .bind(to: viewModel.openNavigationMenu)
            .disposed(by: disposeBag)
        
        // Logout button
        logoutButton.rx.tap
            .clearCurrentOrder()
            .subscribe { _ in SP.authService.signout() }
            .disposed(by: disposeBag)
        
        // Menu buttons
        showMenuButton.rx.tap
            .show(ordering: .menu)
            .disposed(by: disposeBag)
        showOrdersButton.rx.tap
            .show(ordering: .orders)
            .disposed(by: disposeBag)
        showTablesButton.rx.tap
            .show(main: .tablesLayout)
            .disposed(by: disposeBag)
        
        SP.idleManager.idleSecBehaviour
            .asDriver()
            .drive(onNext: { idleSec in
                if idleSec == 0 {
                    self.toolbar.detailLabel.text = ""
                } else {
                    let timeout = self.viewModel.settings.timeout
                    if idleSec < timeout {
                        self.toolbar.detailLabel.text = "Logout in: \(timeout - idleSec)"
                    } else {
                        self.toolbar.detailLabel.text = ""
                        SP.authService.signout()
                    }
                    self.toolbar.setNeedsLayout()
                }
            })
            .disposed(by: disposeBag)

        // Change MainView controller upon main view changed request
        SP.navigation.mainView
            .asDriver()
            .distinctUntilChanged()
            .drive(onNext: { type in
                if type != .ordering {
                    _ = Observable.just(()).clearCurrentOrder().subscribe()
                }
                var controller: UIViewController!
                if let cachedController = self.cachedControllers[type] {
                    controller = cachedController
                } else {
                    controller = type.viewController
                    self.cachedControllers[type] = controller
                }
                
                controller.view.frame = self.rootViewController.view.frame
                self.transition(to: controller) { _ in
                    controller.view.snp.makeConstraints { make in
                        make.centerX.width.bottom.equalToSuperview()
                        make.top.equalTo(self.toolbar.snp.bottom)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // Update session info
        SP.authService.currentIdentity
            .asDriver()
            .drive(onNext: { id in
                self.toolbar.titleLabel.text = id?.store.storeName
                let employeeName = id?.employee.name
                self.navButton.name.text = employeeName
                self.navButton.abbreviation.text = employeeName?.abbreviation
                self.navButton.abbreviation.backgroundColor = employeeName?.color
            })
            .disposed(by: disposeBag)
    }
}

extension MainContentViewType {
    var viewController: UIViewController {
        switch self {
        case .tablesLayout:
            return TablesLayoutController()
        case .ordering:
            return OrderingController()
        case .customers:
            return CustomersController()
        case .transactions:
            return TransactionsController()
        case .totalReport:
            return ByTotalReportController()
        case .transactionReport:
            return ByPaymentTypeReportController()
        case .byServerReport:
            return ByEmployeeReportController()
        case .byShiftAndDayReport:
            return ByShiftAndDayReportController()
        }
    }
}

/// Application bar command button.
class AppBarButton: FlatButton {
    private let theme =  Theme.mainTheme
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init("")
    }
    
    init(_ title: String) {
        super.init(frame: .zero)
        
        self.title = title
        self.titleColor = theme.secondary.base
        self.titleLabel?.font = theme.normalFont
    }
}
