////
////  EditOrderExtraDialog.swift
////  Kiolyn
////
////  Created by Chinh Nguyen on 7/17/17.
////  Copyright © 2017 Willbe Technology. All rights reserved.
////

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// For editing an Order's extra detail.
class EditOrderExtraDialog: KLDialog<Order>, TabBarDelegate {
    
    fileprivate var viewModel: EditOrderExtraDVM!
    fileprivate let selectedTab = BehaviorRelay<KLTabItem?>(value: nil)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Order>) {
        guard let vm = vm as? EditOrderExtraDVM else {
            fatalError("Expecting EditOrderDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    fileprivate var tab = SettingTabBar()
    
    fileprivate lazy var taxes = KLTableView(theme)

    fileprivate lazy var discounts = KLTableView(theme)
    fileprivate var discountPercent = KLPercentField()
    fileprivate var discountReason = KLTextField()
    fileprivate var discountReasonButton = SelectReasonButton()
    fileprivate lazy var discountsView: UIView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = theme.guideline * 2
        view.axis = .vertical
        
        view.addArrangedSubview(discounts)
        
        discountPercent.placeholder = "Percentage (%)"
        discountPercent.placeholderActiveScale = 0.5
        discountPercent.placeholderVerticalOffset = 32.0
        discountPercent.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.addArrangedSubview(discountPercent)
        
        let reasonView = UIStackView()
        reasonView.distribution = .fill
        reasonView.alignment = .fill
        reasonView.axis = .horizontal
        reasonView.spacing = theme.guideline
        reasonView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.addArrangedSubview(reasonView)
        
        discountReason.placeholder = "Reason"
        discountReason.placeholderActiveScale = 0.5
        discountReason.placeholderVerticalOffset = 32.0
        reasonView.addArrangedSubview(discountReason)
        
        discountReasonButton.titleColor = theme.primary.base
        discountReasonButton.fakIcon = FAKFontAwesome.naviconIcon(withSize: 16)
        discountReasonButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        reasonView.addArrangedSubview(discountReasonButton)
        
        return view
    }()
    
    
    fileprivate var ggPercent = KLPercentField()
    fileprivate var ggReason = KLTextField()
    fileprivate var ggReasonButton = SelectReasonButton()
    fileprivate lazy var ggView: UIView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = theme.guideline * 2
        view.axis = .vertical
        
        ggPercent.placeholder = "Percentage (%)"
        ggPercent.placeholderActiveScale = 0.5
        ggPercent.placeholderVerticalOffset = 32.0
        ggPercent.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.addArrangedSubview(ggPercent)
        
        let reasonView = UIStackView()
        reasonView.distribution = .fill
        reasonView.alignment = .fill
        reasonView.axis = .horizontal
        reasonView.spacing = theme.guideline
        reasonView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.addArrangedSubview(reasonView)
        
        ggReason.placeholder = "Reason"
        ggReason.placeholderActiveScale = 0.5
        ggReason.placeholderVerticalOffset = 32.0
        reasonView.addArrangedSubview(ggReason)
        
        ggReasonButton.titleColor = theme.primary.base
        ggReasonButton.fakIcon = FAKFontAwesome.naviconIcon(withSize: 16)
        ggReasonButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        reasonView.addArrangedSubview(ggReasonButton)
        
        let placeholder = UIView()
        view.addArrangedSubview(placeholder)
        
        return view
    }()
    
    fileprivate lazy var sfView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = theme.guideline*2
        view.backgroundColor = .red
        
        let sfAmounts = UIStackView()
        sfAmounts.axis = .vertical
        sfAmounts.distribution = .equalSpacing
        sfAmounts.spacing = theme.guideline
        sfAmounts.alignment = .fill
        sfAmounts.backgroundColor = .green
        view.addArrangedSubview(sfAmounts)
        let amounts: [[Double]] = [
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
            [13, 14, 15, 16],
            [17, 18, 19, 0]
        ]
        for r in amounts {
            sfAmounts.add(row: r.map { a in
                guard a > 0 else { return sfAmount }
                let button = ServiceFeeButton.new(value: (.amount, a), with: theme)
                button.rx.tap
                    .subscribe(onNext: { _ in
                        self.sfPercent.value = 0
                        self.sfAmount.value = a
                    })
                    .disposed(by: disposeBag)
                return button
            }, spacing: theme.guideline)
        }
        
        let sfPercents = UIStackView()
        sfPercents.axis = .vertical
        sfPercents.distribution = .equalSpacing
        sfPercents.spacing = theme.guideline
        sfPercents.alignment = .fill
        sfPercents.backgroundColor = .blue
        view.addArrangedSubview(sfPercents)
        let percents: [[Double]] = [
            [0.01, 0.02, 0.03, 0.04],
            [0.05, 0.06, 0.07, 0.08],
            [0.09, 0.1, 0.11, 0.12],
            [0.13, 0.14, 0.15, 0.16],
            [0.17, 0.18, 0.19, 0]
        ]
        for r in percents {
            sfPercents.add(row: r.map { a in
                guard a > 0 else { return sfPercent }
                let button = ServiceFeeButton.new(value: (.percentage, a), with: theme)
                button.rx.tap
                    .subscribe(onNext: { _ in
                        self.sfPercent.value = a
                        self.sfAmount.value = 0
                    })
                    .disposed(by: disposeBag)
                return button
            }, spacing: theme.guideline)
        }
        return view
    }()
    
    fileprivate let sfAmountRows: [UIStackView] = []
    fileprivate let sfPercentRows: [UIStackView] = []
    
    fileprivate let sfAmount = KLCashField()
    fileprivate let sfPercent = KLPercentField()
    
    fileprivate var contents: [KLTabItem: (UIView, UITextField?)]!
    
    override var dialogWidth: CGFloat { return 540 }
    override var dialogHeight: CGFloat { return 600 }
    
    /// Return the keyboard mapping
    override var textFields: [(KLTextField, KLKeyboard)] {
        return [
            (discountPercent, numpad),
            (discountReason, textKeyboard),
            (ggPercent, numpad),
            (ggReason, textKeyboard),
            (sfAmount, numpad),
            (sfPercent, numpad),
        ]
    }
    
    override func makeDialogToolbar() -> UIView? {
        let toolbar = UIView()
        toolbar.backgroundColor = theme.headerBackground
        toolbar.layoutEdgeInsets = EdgeInsets(top: 4, left: 12, bottom: 4, right: 4)
        // Close button
        toolbar.addSubview(dialogCloseButton)
        dialogCloseButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(theme.buttonHeight)
        }
        // Tabs
        let taxes = KLTabItem()
        taxes.title = "TAXES"
        
        let discounts = KLTabItem()
        discounts.title = "DISCOUNTS"
        
        let gg = KLTabItem()
        gg.titleLabel?.numberOfLines = 2
        gg.titleLabel?.textAlignment = .center
        gg.title = "GROUP\nGRATUITY"

        let sf = KLTabItem()
        sf.title = "SERVICE FEE"

        tab.tabItems = [taxes, discounts, gg, sf]
        tab.tabBarStyle = .nonScrollable
        tab.tabItemsInterimSpacePreset = .none
        tab.backgroundColor = theme.headerBackground
        tab.lineColor = theme.warn.base
        tab.lineHeight = 4
        tab.delegate = self
        toolbar.addSubview(tab)
        tab.snp.makeConstraints { make in
            make.leading.height.centerY.equalToSuperview()
            make.trailing.equalTo(dialogCloseButton.snp.leading)
        }
        
        contents = [
            taxes: (self.taxes, nil),
            discounts: (discountsView, discountPercent),
            gg: (ggView, ggPercent),
            sf: (sfView, sfAmount)
        ]
        return toolbar
    }

    override func makeDialogContentView() -> UIView? {
        let view = UIView()
        // Define the tabs content
        for v in contents {
            let contentView = v.value.0
            contentView.isHidden = true
            view.addSubview(contentView)
        }
        // Change content on tab change
        selectedTab
            .asDriver()
            .filterNil()
            .drive(onNext: { tab in
                UIView.animate(withDuration: 0.2) {
                    for t in self.contents.enumerated() {
                        t.element.value.0.isHidden = tab != t.element.key
                    }
                }
                if let fr = self.contents[tab]?.1 {
                    _ = fr.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        return view
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        for v in contents {
            let contentView = v.value.0
            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(theme.guideline*2)
            }
        }
        discountPercent.snp.makeConstraints { make in
            make.height.equalTo(theme.buttonHeight)
        }
        discountReason.snp.makeConstraints { make in
            make.height.equalTo(theme.buttonHeight)
        }
        
        ggPercent.snp.makeConstraints { make in
            make.height.equalTo(theme.buttonHeight)
        }
        ggReason.snp.makeConstraints { make in
            make.height.equalTo(theme.buttonHeight)
        }
    }
    
    override func prepare() {
        super.prepare()
        
        // TAXES
        taxes.register(SelectableTaxCell.self, forCellReuseIdentifier: "Cell")
        taxes.rowHeight = theme.largeButtonHeight
        Observable
            .just([Tax.noTax] + viewModel.settings.taxes)
            .bind(to: taxes.rx.items) { (tableView, row, tax) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SelectableTaxCell
                cell.item = tax
                cell.disposeBag = DisposeBag()
                self.viewModel.selectedTax
                    .asDriver()
                    .map { selectedTax, _ in selectedTax.id == tax.id }
                    .drive(cell.rx.isSelected)
                    .disposed(by: cell.disposeBag!)
                return cell
            }
            .disposed(by: disposeBag)
        // Save the result and close dialog upon selecting of an item
        taxes.rx.modelSelected(Tax.self)
            .bind(to: viewModel.changeTax)
            .disposed(by: disposeBag)

        // DISCOUNTS
        discounts.register(SelectableDiscountCell.self, forCellReuseIdentifier: "Cell")
        discounts.rowHeight = theme.largeButtonHeight
        Observable
            .just([Discount.noDiscount] + viewModel.settings.discounts.filter({ discount -> Bool in
                if let employee = SP.authService.currentIdentity.value?.employee, employee.permissions.maxDiscountPercent < discount.percent {
                    return false
                }
                return true
            }))
            .bind(to: discounts.rx.items) { (tableView, row, discount) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SelectableDiscountCell
                cell.item = discount
                cell.disposeBag = DisposeBag()
                self.viewModel.selectedDiscount
                    .asDriver()
                    .map { selectedDiscount in selectedDiscount.id == discount.id }
                    .drive(cell.rx.isSelected)
                    .disposed(by: cell.disposeBag!)
                return cell
            }
            .disposed(by: disposeBag)
        viewModel.selectedDiscount
            .asObservable()
            .subscribe(onNext: { discount in
                // update text fields
                self.discountPercent.value = discount.adjustedPercent
                self.discountReason.text = discount.adjustedReason
                // udpate adjusment area status
                self.discountPercent.isEnabled = discount.percent > 0
                self.discountReason.isEnabled = discount.percent > 0
                self.discountReasonButton.isEnabled = discount.percent > 0
            })
            .disposed(by: disposeBag)
        // Save the result and close dialog upon selecting of an item
        discounts.rx.modelSelected(Discount.self)
            .map { d in
                let discount: Discount = d.clone()
                discount.adjustedPercent = discount.percent
                discount.adjustedReason = ""
                // update the max discount of discountPercent
                self.discountPercent.maxValue = discount.percent
                return discount
            }
            .bind(to: viewModel.selectedDiscount)
            .disposed(by: disposeBag)

        discountPercent.rx.value
            .asObservable()
            .bind(to: viewModel.discountAdjustedPercent)
            .disposed(by: disposeBag)
        discountReason.rx.text.changed
            .bind(to: viewModel.discountAdjustedReason)
            .disposed(by: disposeBag)
        discountReasonButton.rx.tap
            .bind(to: viewModel.selectDiscountReason)
            .disposed(by: disposeBag)
        viewModel.discountReasonSelected
            .drive(discountReason.rx.text)
            .disposed(by: disposeBag)


        // GROUP GRATUITY
        // Calculate the Max Service Fee (a.k.a Service Fee)
        // this is to limit the edited value of Service Fee to
        // the one in settings
        ggPercent.isEnabled = false
        ggReason.isEnabled = false
        if let gg = viewModel.settings.find(groupGratuity: viewModel.order.persons) {
            ggPercent.maxValue = gg.percent
            ggPercent.isEnabled = ggPercent.maxValue > 0
            ggReason.isEnabled = ggPercent.maxValue > 0
            ggPercent.placeholder = "Percentage (max \(gg.percent.asPercentage))"
        }
        ggPercent.value = viewModel.ggPercent.value
        ggReason.text = viewModel.ggReason.value
        ggPercent.rx.value
            .asObservable()
            .bind(to: viewModel.ggPercent)
            .disposed(by: disposeBag)
        ggReason.rx.text.changed
            .bind(to: viewModel.ggReason)
            .disposed(by: disposeBag)
        ggReasonButton.rx.tap
            .bind(to: viewModel.selectGGReason)
            .disposed(by: disposeBag)
        viewModel.ggReasonSelected
            .drive(ggReason.rx.text)
            .disposed(by: disposeBag)

        // SERVICE FEE
        sfAmount.value = viewModel.sfAmount.value
        sfAmount.rx.doubleValue
            .asObservable()
            .bind(to: viewModel.sfAmount)
            .disposed(by: disposeBag)
        sfPercent.value = viewModel.sfPercent.value
        sfPercent.rx.value
            .asObservable()
            .bind(to: viewModel.sfPercent)
            .disposed(by: disposeBag)

        // We need this keyboard to enable saving when on Tax screen where there is no text field
        viewModel.dialogDidAppear
            .subscribe(onNext: {
                self.keyboard = self.numpad
                self.tab.select(at: self.viewModel.initialTabIndex)
                self.selectedTab.accept(self.tab.tabItems[self.viewModel.initialTabIndex] as? KLTabItem)
            })
            .disposed(by: disposeBag)
    }
    
    func tabBar(tabBar: TabBar, didSelect tabItem: TabItem) {
        selectedTab.accept(tabItem as? KLTabItem)
    }
}

/// For displaying inside KLTabBar
fileprivate class KLTabItem: TabItem {
    override func prepare() {
        super.prepare()
        titleColor = Theme.dark.textColor
        backgroundColor = Theme.dialogTheme.headerBackground
        titleLabel?.font = Theme.dialogTheme.normalBoldFont
    }
}

fileprivate class SettingTabBar: TabBar {
    let theme = Theme.dialogTheme
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: max(size.height, theme.dialogToolbarHeight))
    }
}

fileprivate class SelectReasonButton: KLFlatButton {
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: max(size.width, theme.normalButtonHeight), height: max(size.height, theme.normalButtonHeight))
    }
}

// MARK: - Special extension to format the row
fileprivate extension UIStackView {
    func add(row views: [UIView], spacing: CGFloat = 0) {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = spacing
        for v in views { row.addArrangedSubview(v) }
        self.addArrangedSubview(row)
    }
}

fileprivate class SelectableObjectModelCell<T: BaseModel>: SelectItemTableViewCell<T> {
    let toggle = KLDataTableRowCheckButton()
    
    override var isSelected: Bool {
        didSet {
            toggle.isSelected = isSelected
            setNeedsUpdateConstraints()
        }
    }
    
    override func prepare() {
        super.prepare()
        
        toggle.isUserInteractionEnabled = false
        addSubview(toggle)
        toggle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(theme.buttonHeight)
        }
        
        textLabel?.snp.makeConstraints{ make in
            make.leading.equalToSuperview().offset(theme.guideline*3 + theme.buttonHeight)
            make.trailing.centerY.equalToSuperview()
        }
    }
}

fileprivate class SelectableTaxCell: SelectableObjectModelCell<Tax> {}
fileprivate class SelectableDiscountCell: SelectableObjectModelCell<Discount> {}

