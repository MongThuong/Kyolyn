//
//  OrderItemFilterView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/25/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift

// Filter button
class OrderItemFilterButton: KLPrimaryRaisedButton {
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: theme.smallButtonHeight)
    }
}

/// For displaying filter.
class OrderItemFilterView: KLView {
    private let theme = Theme.mainTheme
    private let disposeBag = DisposeBag()
    private var viewModel: OrderDetailViewModel!
    
    private let row = UIStackView()
    private let sep = KLLine()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ viewModel: OrderDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0, y: 0, width: theme.orderDetailViewWidth, height: theme.smallButtonHeight))
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: theme.orderDetailViewWidth, height: theme.smallButtonHeight + theme.guideline)
    }
    
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        
        row.distribution = .fillEqually
        row.axis = .horizontal
        row.alignment = .fill
        row.spacing = theme.guideline/2
        for t: OrderItemFilterType in [.all, .none] {
            let b = OrderItemFilterButton()
            b.title = t.text
            b.rx.tap
                .bind(to: viewModel.removeBill)
                .disposed(by: disposeBag)
            b.rx.tap
                .map { t }
                .bind(to: viewModel.applyFilter)
                .disposed(by: disposeBag)
            row.addArrangedSubview(b)
        }
        addSubview(row)
        row.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(theme.guideline/2)
        }
        
        addSubview(sep)
        sep.snp.makeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
        }
    }
}
