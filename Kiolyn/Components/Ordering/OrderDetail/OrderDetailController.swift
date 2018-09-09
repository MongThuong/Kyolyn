//
//  OrderDetailController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import Material
import FontAwesomeKit
import MaterialComponents.MaterialSlider
import SwiftyUserDefaults

/// For controlling the display of order detail.
class OrderDetailController: UIViewController {
    let theme =  Theme.mainTheme
    let disposeBag = DisposeBag()
    
    let orderInfo = OrderInfoButton()
    lazy var orderItemFilter = OrderItemFilterView(viewModel)
    let orderExtraInfo = OrderExtraInfoButton()
    let orderItems = OrderItemsList()
    lazy var orderActions = OrderActions(viewModel)

    let wrapper = UIStackView()
    let empty = Material.FlatButton()
    
    let viewModel = OrderDetailViewModel()
    
    // Settings Area
    lazy var settingAreaView = OrderSettingsAreaView(viewModel)
    var firstScale: CFloat = 1.0
    
    // check to show settings area
    let settingsArea = BehaviorRelay<Bool>(value: false)
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = theme.cardBackgroundColor

        // MARK: - Empty
        empty.backgroundColor = theme.cardBackgroundColor
        empty.title = "EMPTY ORDER!\nCLICK TO CREATE NEW ORDER"
        empty.titleColor = theme.primary.darken4
        empty.titleLabel?.font = theme.heading2BoldFont
        empty.titleLabel?.numberOfLines = 2
        empty.titleLabel?.textAlignment = .center
        view.addSubview(empty)
        empty.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // MARK: - Settings Area
        settingAreaView.backgroundColor = UIColor.clear
        view.addSubview(settingAreaView)
        settingAreaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // handle show/hide by order -> check in the first time when open ordering view controller
        SP.navigation.orderingInteractionView
        .asDriver()
        .drive(onNext: { type in
            // change to hide all
            if let _: Order = self.viewModel.orderManager.order.value {
                self.settingAreaView.isHidden = true
                self.empty.isHidden = true
            } else {
                self.settingAreaView.isHidden = type != .menu
                self.empty.isHidden = type != .orders
            }
        })
        .disposed(by: disposeBag)
        
        
        // handle to show/ hide settings area
        settingsArea.subscribe(onNext: { showSettings in
            self.settingAreaView.isHidden = !showSettings
            self.empty.isHidden = showSettings
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        // handle show / hide by number of order
        viewModel.orderManager.order
            .asDriver()
            .map { $0 != nil }
            .drive(onNext: { hidden in
                if hidden == true {
                    self.settingAreaView.isHidden = true
                    self.empty.isHidden = true
                } else {
                    self.settingAreaView.isHidden = SP.navigation.orderingInteractionView.value != .menu
                    self.empty.isHidden = SP.navigation.orderingInteractionView.value != .orders
                }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        empty.rx.tap
            .bind(to: viewModel.newOrder)
            .disposed(by: disposeBag)
        
        // MARK: - Order detail wrapper
        wrapper.axis = .vertical
        wrapper.spacing = 0
        wrapper.alignment = .fill
        wrapper.distribution = .fill
        view.addSubview(wrapper)
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewModel.orderManager.order
            .asDriver()
            .map { $0 == nil }
            .drive(wrapper.rx.isHidden)
            .disposed(by: disposeBag)

        // Order Info (customer/table)
        orderInfo.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(orderInfo)
        orderInfo.rx.tap.bind(to: viewModel.editOrder).disposed(by: disposeBag)

        // Items Filter
        orderItemFilter.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(orderItemFilter)
        
        // Order Items
        orderItems.register(OrderItemCell.self, forCellReuseIdentifier: "orderItem")
        orderItems.size = viewModel.settings.ordering.orderItemSize
        wrapper.addArrangedSubview(orderItems)
        viewModel.orderManager.order
            .asDriver()
            .filterNil()
            .map { $0.items }
            .drive(orderItems.rx.items) { (tableView, row, item) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "orderItem") as! OrderItemCell
                cell.detailView.size = self.orderItems.size
                let selectedItems = self.viewModel.selectedOrderItems.value
                cell.isSelected = selectedItems.contains(item.id)
                cell.orderItem = item
                // Can remove if order item is new one
                cell.removeButton.isEnabled = item.isNew
                    // or a submitted one and ...
                    || (item.isSubmitted
                        // ... the current employee has the right permission
                        && self.viewModel.employee.permissions.deleteEditSentItem)
                cell.disposeBag = DisposeBag()
                // Remove the item clicking on remove button
                cell.removeButton.rx.tap
                    .map { item }
                    .bind(to: self.viewModel.remove)
                    .disposed(by: cell.disposeBag!)
                // Select item clicking on the image button
                cell.imageButton.rx.tap
                    .map { item }
                    .bind(to: self.viewModel.toggleSelectedItem)
                    .disposed(by: cell.disposeBag!)
                return cell
            }
            .disposed(by: disposeBag)
        orderItems.rx.modelSelected(OrderItem.self)
            .bind(to: viewModel.editOrderItem)
            .disposed(by: disposeBag)
        
        // Order Summary (tax/subtotal/total)
        orderExtraInfo.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(orderExtraInfo)
        orderExtraInfo.rx.tap.bind(to: viewModel.editOrderExtra).disposed(by: disposeBag)

        // Order Actions
        orderActions.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        wrapper.addArrangedSubview(orderActions)
        
        // Update view based on order changed
        viewModel.orderManager.order
            .asDriver()
            .filterNil()
            .drive(onNext: { self.update(view: $0) })
            .disposed(by: disposeBag)

        // for programmatically update the selected item/cell
        viewModel.selectedOrderItems
            .asDriver()
            .drive(onNext: { _ in
                self.orderItems.reloadData()
                self.orderItems.scrollToBottom()
            })
            .disposed(by: disposeBag)

        // Disable the whole view when bills in in moving mode
        NotificationCenter.default.rx
            .notification(Notification.Name.klBillsMovingModeChanged)
            .map { notif -> Bill? in notif.userInfo?["movingBill"] as? Bill }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { movingBill in
                let enabled = movingBill == nil
                self.view.isUserInteractionEnabled = enabled
                self.view.alpha = enabled ? 1.0 : 0.25
            })
            .disposed(by: disposeBag)
        
        // scroll to bottom
        self.rx.viewWillAppear
        .asObservable()
        .subscribe(onNext: { _ in
            self.orderItems.scrollToBottom()
        })
        .disposed(by: disposeBag)
    }
    
    
    private func update(view order: Order) {
        // Update info and summary
        orderInfo.orderInfo.order = order
        orderExtraInfo.summary.orderItemsContainer = order
        // Update status
        orderInfo.isEnabled = order.mutable
        orderExtraInfo.isEnabled = order.mutable
        
        orderExtraInfo.status.isHidden = order.isNew
        orderExtraInfo.status.textColor = order.orderStatus.color(theme)
        orderExtraInfo.status.fakIcon = order.orderStatus.icon(withSize: 24.0)
        
        orderItems.isUserInteractionEnabled = order.isNotClosed
        orderItemFilter.isUserInteractionEnabled = order.isNotClosed
        
        orderItems.alpha = order.isNotClosed ? 1.0 : 0.25
        orderItemFilter.alpha = order.isNotClosed ? 1.0 : 0.25
        
        orderExtraInfo.invalidateIntrinsicContentSize()
        orderExtraInfo.layoutIfNeeded()
    }
}

// Mapping OrderStatus to its icon
fileprivate extension OrderStatus {
    func icon(withSize size: CGFloat) -> FAKIcon {
        switch self {
        case .submitted:
            return FAKFontAwesome.printIcon(withSize: size)
        case .checked:
            return FAKFontAwesome.dollarIcon(withSize: size)
        case .printed:
            return FAKFontAwesome.checkIcon(withSize: size)
        case .voided:
            return FAKFontAwesome.banIcon(withSize: size)
        case .new:
            return FAKFontAwesome.fileIcon(withSize: size)
        }
    }

    func color(_ theme: Theme) -> UIColor {
        switch self {
        case .submitted:
            return theme.secondary.base
        case .checked:
            return theme.warn.base
        case .printed:
            return theme.secondary.base
        case .voided:
            return theme.warn.base
        case .new:
            return theme.secondary.base
        }
    }
}
