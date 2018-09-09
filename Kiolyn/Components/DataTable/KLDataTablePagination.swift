//
//  KLDataTablePagination.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/15/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FontAwesomeKit

/// For handling the displaying of pagination.
class KLDataTablePagination : KLView {
    fileprivate let disposeBag = DisposeBag()
    fileprivate var theme: Theme!
    
    fileprivate var pageSizes = BehaviorRelay<[UInt]>(value: [10, 20, 50])
    fileprivate var pages = BehaviorRelay<[KLDataTablePaginationPage]>(value: [])
    
    var selectedPageSize = BehaviorRelay<UInt>(value: 10)
    var selectedPage = BehaviorRelay<UInt>(value: 1)
    var total = BehaviorRelay<Int>(value: 0)
    
    fileprivate let totalLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
    }
    
    init(_ theme: Theme = Theme.mainTheme) {
        self.theme = theme
        super.init(frame: .zero)
    }
    
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        
        totalLabel.font = theme.smallFont
        totalLabel.textColor = theme.textColor
        totalLabel.textAlignment = .right
        addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-theme.guideline)
        }
        
        let leftViews = UIStackView()
        leftViews.axis = .horizontal
        leftViews.distribution = .fill
        leftViews.alignment = .leading
        addSubview(leftViews)
        leftViews.snp.makeConstraints { make in
            make.left.centerY.height.equalToSuperview()
        }
        Driver.combineLatest(
            pageSizes.asDriver().distinctUntilChanged(),
            selectedPageSize.asDriver().distinctUntilChanged())
            .drive(onNext: { sizes, selected in
                for v in leftViews.subviews {
                    v.isHidden = true
                }
                for (index, s) in sizes.enumerated() {
                    var button: KLDataTablePaginationButton!
                    if index < leftViews.subviews.count {
                        button = leftViews.subviews[index] as? KLDataTablePaginationButton
                    }
                    if button == nil {
                        button = KLDataTablePaginationButton()
                        leftViews.addArrangedSubview(button!)
                        button.snp.makeConstraints { make in
                            make.width.height.equalTo(self.theme.buttonHeight)
                            make.centerY.equalToSuperview()
                        }
                    }
                    button.isHidden = false
                    button.title = "\(s)"
                    button.isSelected = s == selected
                    button.disposeBag = DisposeBag()
                    button.rx.tap
                        .map { s }
                        .bind(to: self.selectedPageSize)
                        .disposed(by: button.disposeBag!)
                }
            })
            .disposed(by: disposeBag)
        
        let centerViews = UIStackView()
        centerViews.axis = .horizontal
        centerViews.distribution = .fill
        centerViews.alignment = .center
        addSubview(centerViews)
        centerViews.snp.makeConstraints { make in
            make.centerX.centerY.height.equalToSuperview()
        }
        Driver.combineLatest(
            pages.asDriver().distinctUntilChanged(),
            selectedPage.asDriver().distinctUntilChanged())
            .drive(onNext: { pages, current in
                for v in centerViews.subviews {
                    v.isHidden = true
                }
                for (index, p) in pages.enumerated() {
                    var button: KLDataTablePaginationButton!
                    if index < centerViews.subviews.count {
                        button = centerViews.subviews[index] as? KLDataTablePaginationButton
                    }
                    if button == nil {
                        button = KLDataTablePaginationButton()
                        centerViews.addArrangedSubview(button!)
                        button.snp.makeConstraints{ make in
                            make.width.height.equalTo(self.theme.buttonHeight)
                            make.centerY.equalToSuperview()
                        }
                    }
                    if p.type == "first" {
                        button.set(icon: FAKFontAwesome.angleDoubleLeftIcon(withSize: 20.0))
                    } else if p.type == "prev" {
                        button.set(icon: FAKFontAwesome.angleLeftIcon(withSize: 20.0))
                    } else if p.type == "next" {
                        button.set(icon: FAKFontAwesome.angleRightIcon(withSize: 20.0))
                    } else if p.type == "last" {
                        button.set(icon: FAKFontAwesome.angleDoubleRightIcon(withSize: 20.0))
                    } else if p.type == "page" {
                        let attrString = NSMutableAttributedString(string: "\(p.number)")
                        attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: button.titleColor(for: .normal) as Any, range: NSMakeRange(0, attrString.length))
                        button.setAttributedTitle(attrString, for: .normal)
                    }
                    button.isHidden = false
                    button.isEnabled = p.active
                    button.isSelected = p.number == current
                    button.disposeBag = DisposeBag()
                    button.rx.tap
                        .map { p.number }
                        .bind(to: self.selectedPage)
                        .disposed(by: button.disposeBag!)
                }
            })
            .disposed(by: disposeBag)
        
        total
            .asObservable()
            .map { total -> [KLDataTablePaginationPage] in
                var pages = [KLDataTablePaginationPage]()
                let pageSize = Double(self.selectedPageSize.value)
                let currentPage: Int = Int(self.selectedPage.value)
                guard pageSize > 0, currentPage > 0 else { return pages }
                
                // Find the number of pages
                let numPages: Int = Int(ceil(Double(total)/pageSize))
                guard numPages > 1 else { return pages }
                
                pages.append(KLDataTablePaginationPage("first", 1, currentPage > 1, currentPage == 1))
                pages.append(KLDataTablePaginationPage("prev", max(1, currentPage &- 1), currentPage > 1))
                
                let maxPivotPages: Int = 2
                var minPage: Int = max(2, currentPage - maxPivotPages)
                let maxPage: Int = min(numPages - 1, currentPage + maxPivotPages * 2 - (currentPage - minPage))
                minPage = max(2, minPage - (maxPivotPages * 2 - (maxPage - minPage)))
                var i = minPage;
                while i <= maxPage {
                    if (i == minPage && i != 2) || (i == maxPage && i != numPages - 1) {
                        pages.append(KLDataTablePaginationPage("more"))
                    } else {
                        pages.append(KLDataTablePaginationPage("page", i, currentPage != i, currentPage == i))
                    }
                    i += 1
                }
                pages.append(KLDataTablePaginationPage("next", min(numPages, currentPage + 1), currentPage < numPages))
                pages.append(KLDataTablePaginationPage("last", numPages, currentPage != numPages, currentPage == numPages))
                return pages
            }
            .bind(to: pages)
            .disposed(by: disposeBag)
        
        total
            .asObservable()
            .map { "\($0) total" }
            .bind(to: totalLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

/// For keep the page display information.
fileprivate class KLDataTablePaginationPage: Equatable {
    var type: String = ""
    var number: UInt = 0
    var active: Bool = false
    var current: Bool = false
    
    init(_ type: String, _ number: Int = 0, _ active: Bool = false, _ current: Bool = false) {
        self.type = type
        self.number = UInt(number)
        self.active = active
        self.current = current
    }
}

fileprivate func == (lhs: KLDataTablePaginationPage, rhs: KLDataTablePaginationPage) -> Bool {
    return lhs.type == rhs.type && lhs.number == rhs.number && lhs.active == rhs.active && lhs.current == rhs.current
}

/// For displaying buttons inside pagination area.
fileprivate class KLDataTablePaginationButton : KLFlatButton {
    var disposeBag: DisposeBag?
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            UIView.animate(withDuration: 0.2, animations: {
                self.titleColor = self.isSelected ? self.theme.secondary.base : self.theme.textColor
            })
        }
    }
    
    override func prepare() {
        super.prepare()
        titleLabel?.font = theme.smallFont
        contentEdgeInsetsPreset = .square1
    }
}
