//
//  MainNavigationController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// Control things that shown inside the menu drawer.
class MainNavigationController: UIViewController {
    let theme =  Theme.menuTheme
    let disposeBag = DisposeBag()
    
    private static let iconSize = Theme.menuTheme.navigationIconSize
    
    // MARK: - The navigation items
    let customers = MenuNavigationItem("CUSTOMERS", withIcon: FAKFontAwesome.userPlusIcon(withSize: iconSize))
    let transactions = MenuNavigationItem("TRANSACTIONS", withIcon: FAKFontAwesome.creditCardIcon(withSize: iconSize))
    let refund = MenuNavigationItem("REFUND", withIcon: FAKFontAwesome.replyIcon(withSize: iconSize))
    let force = MenuNavigationItem("FORCE", withIcon: FAKFontAwesome.shareIcon(withSize: iconSize))
    let openCashDrawer = MenuNavigationItem("OPEN CASH DRAWER", withIcon: FAKFontAwesome.moneyIcon(withSize: iconSize))

    let totalReport = MenuNavigationItem("TOTAL REPORT", withIcon: FAKFontAwesome.lineChartIcon(withSize: iconSize))
    let detailReport = MenuNavigationItem("DETAIL REPORT", withIcon: FAKFontAwesome.areaChartIcon(withSize: iconSize))
    let serverReport = MenuNavigationItem("SERVER REPORT", withIcon: FAKFontAwesome.usersIcon(withSize: iconSize))
    let shiftAndDayReport = MenuNavigationItem("SHIFT & DAY REPORT", withIcon: FAKFontAwesome.barChartIcon(withSize: iconSize))

    let openCloseShift = MenuNavigationItem("OPEN SHIFT", withIcon: FAKFontAwesome.clockOIcon(withSize: iconSize))

    var separator: NavigationItem { return MenuNavigationItemSeparator() }

    /// The view model.
    let viewModel: MainViewModel
    
    /// Shortcut for checking main/sub status
    var isMain: Bool { return SP.stationManager.status.value.isMain }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = theme.backgroundColor
        
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.distribution = .fill
        wrapper.alignment = .fill
        view.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let mainNavigation = NavigationTableView()
        wrapper.addArrangedSubview(mainNavigation)
        rx.viewWillAppear
            .map { _ -> [NavigationItem] in
                let permissions = self.viewModel.employee.permissions
                var items = permissions.customer ? [self.customers, self.separator] : []
                if self.isMain {
                    items.append(self.transactions)
                }
                if permissions.refundVoidUnpaidSettle {
                    items.append(self.refund)
                }
                items.append(contentsOf: [self.force, self.separator, self.openCashDrawer, self.separator])
                if self.isMain, permissions.report {
                    items.append(contentsOf: [self.totalReport, self.detailReport, self.serverReport, self.shiftAndDayReport, self.separator])
                }
                return items
            }
            .bind(to: mainNavigation.items)
            .disposed(by: disposeBag)
        
        let bottomNavigation = NavigationTableView()
        bottomNavigation.setContentHuggingPriority(.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(bottomNavigation)
        bottomNavigation.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(self.theme.mediumButtonHeight)
        }
        rx.viewWillAppear
            .map { _ -> [NavigationItem] in
                self.isMain ? [ self.separator, self.openCloseShift ] : []
            }
            .bind(to: bottomNavigation.items)
            .disposed(by: disposeBag)
        bottomNavigation.items
            .map { items in items.isEmpty }
            .bind(to: bottomNavigation.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Update button text based on shift status
        SP.dataService
            .activeShift
            .asDriver()
            .drive(onNext: { shift in
                self.openCloseShift.name = shift == nil
                    ? "OPEN SHIFT"
                    : "CLOSE SHIFT"
                bottomNavigation.reloadData()
            })
            .disposed(by: disposeBag)

        let statusLabel = UILabel()
        statusLabel.font = theme.xsmallFont
        statusLabel.textColor = theme.textColor
        statusLabel.alpha = 0.75
        statusLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.height.equalTo(self.theme.smallButtonHeight)
        }
        SP.stationManager.status
            .asDriver()
            .map { status in  " \(status.asString) " }
            .drive(statusLabel.rx.text)
            .disposed(by: disposeBag)

        customers.onSelected
            .show(main: .customers)
            .disposed(by: disposeBag)
        transactions.onSelected
            .show(main: .transactions)
            .disposed(by: disposeBag)
        refund.onSelected
            .bind(to: viewModel.refund)
            .disposed(by: disposeBag)
        force.onSelected
            .bind(to: viewModel.force)
            .disposed(by: disposeBag)
        openCashDrawer.onSelected
            .bind(to: viewModel.openCashDrawer)
            .disposed(by: disposeBag)
        totalReport.onSelected
            .show(main: .totalReport)
            .disposed(by: disposeBag)
        detailReport.onSelected
            .show(main: .transactionReport)
            .disposed(by: disposeBag)
        serverReport.onSelected
            .show(main: .byServerReport)
            .disposed(by: disposeBag)
        shiftAndDayReport.onSelected
            .show(main: .byShiftAndDayReport)
            .disposed(by: disposeBag)
        openCloseShift.onSelected
            .bind(to: viewModel.openCloseShift)
            .disposed(by: disposeBag)
    }
}
