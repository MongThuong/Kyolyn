//
//  DataTableController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/3/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import DRPLoadingSpinner
import FontAwesomeKit
import ObjectMapper

class DataTableController<R: QueryResult<T>, T: Mappable & Equatable>: UIViewController {
    let theme = Theme.mainTheme
    let disposeBag = DisposeBag()
    
    /// The root of of content view
    let rootView = UIStackView()
    
    /// The content
    let contentView = UIStackView()
    
    /// The Bar
    let bar = KLBar()
    /// Refresh button
    let refresh = KLBarPrimaryRaisedButton()
    
    /// The main table
    let table = KLDataTable<R, T>()
    let columns = BehaviorRelay<[KLDataTableColumn<T>]>(value: [])
    let summaryCells = BehaviorRelay<[KLDataTableSummaryCell]>(value: [])
    
    /// For displaying loading indicator
    var loading = DRPLoadingSpinner()
    
    /// The view model
    var viewModel: DataTableViewModel<R, T>!
    
    /// Root view margin comparing to container
    var rootViewMargin: CGFloat {
        return theme.guideline/2
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init(_ viewModel: DataTableViewModel<R, T> = DataTableViewModel<R, T>()) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    /// Extra setting of a item to row.
    func on(assigned item: T, to row: KLDataTableRow<T>) {
        // Nothing by default
    }
    
    func allCellsDidDisplayed() {
        // Nothing by default
    }
    
    /// Child class override to provide different views arrangement
    func setupDataTable() {
        
        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.distribution = .fill
        
        refresh.fakIcon = FAKFontAwesome.refreshIcon(withSize: 16.0)

        bar.rightViews = [refresh]
        bar.setContentHuggingPriority(.defaultHigh, for: .vertical)
        contentView.addArrangedSubview(bar)
        bar.snp.makeConstraints { make in
            make.height.equalTo(theme.normalButtonHeight)
            make.width.equalToSuperview()
        }
        
        contentView.addArrangedSubview(table)
        table.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        // Loading indicator
        let loadingSize = theme.mediumButtonHeight
        loading.frame = CGRect(x: 0, y: 0, width: loadingSize, height: loadingSize)
        loading.colorSequence = [theme.secondary.base]
        loading.lineWidth = 3
        loading.startAnimating()
        contentView.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(loadingSize)
            make.centerX.equalTo(table.snp.centerX)
            make.centerY.equalTo(table.snp.centerY)
        }
        
        // Reload binding
        Observable
            .merge(
                // Reload on very first appearing time
                rx.viewDidAppear.mapToVoid(),
                // Reload on tapping of refresh button
                refresh.rx.tap.asObservable())
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        // Binding data around
        columns
            .asDriver()
            .drive(onNext: { columns in self.table.columns = columns })
            .disposed(by: disposeBag)
        summaryCells
            .asDriver()
            .drive(onNext: { summaryCells in self.table.summaryCells = summaryCells })
            .disposed(by: disposeBag)
        viewModel.data
            .asDriver()
            .map { $0.rows }
            .drive(table.table.rx.items) { (tableView, row, item) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! KLDataTableRow<T>
                cell.columns = self.columns.value
                cell.item = item
                if let selectedItem = self.viewModel.selectedRow.value {
                    cell.isSelected = item == selectedItem
                }
                self.on(assigned: item, to: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        // modelSelected => viewModel.selectOrder
        table.table.rx.modelSelected(T.self)
            .bind(to: viewModel.selectedRow)
            .disposed(by: disposeBag)
        table.table.rx.itemSelected
            .asDriver()
            .drive(onNext: { self.table.table.cellForRow(at: $0)?.isSelected = true })
            .disposed(by: disposeBag)
        table.table.rx.itemDeselected
            .asDriver()
            .drive(onNext: { self.table.table.cellForRow(at: $0)?.isSelected = false })
            .disposed(by: disposeBag)
        
        // footer
        viewModel.data
            .asDriver()
            .map { $0.summary }
            .drive(onNext: { self.table.summary.summary = $0 })
            .disposed(by: disposeBag)
        
        // pagination
        viewModel.data
            .asDriver()
            .map { $0.summary.rowCount }
            .drive(table.pagination.total)
            .disposed(by: disposeBag)
        // Page and PageSize changed
        table.pagination.selectedPage
            .asObservable()
            .bind(to: viewModel.page)
            .disposed(by: disposeBag)
        table.pagination.selectedPageSize
            .asObservable()
            .bind(to: viewModel.pageSize)
            .disposed(by: disposeBag)
        
        viewModel.viewStatus
            .asDriver()
            .drive(onNext: { status in
                UIView.animate(withDuration: 0.3) {
                    if status.isLoading {
                        self.bar.isUserInteractionEnabled = false
                        self.loading.startAnimating()
                        self.loading.isHidden = false
                        self.table.isHidden = true
                    } else {
                        self.bar.isUserInteractionEnabled = true
                        self.table.isHidden = false
                        self.loading.isHidden = true
                        self.loading.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func layoutRootView() {
        let contentBackgroundView = UIView()
        contentBackgroundView.backgroundColor = theme.cardBackgroundColor
        rootView.addSubview(contentBackgroundView)
        contentBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentBackgroundView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = theme.backgroundColor
        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(rootViewMargin)
        }

        layoutRootView()
        setupDataTable()
    }
}

/// Use `QueryResult` as result of data loading.
class CommonDataTableController<T: Mappable & Equatable> : DataTableController<QueryResult<T>, T> {
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override init(_ viewModel: DataTableViewModel<QueryResult<T>, T> = DataTableViewModel<QueryResult<T>, T>()) {
        super.init(viewModel)
    }
}
