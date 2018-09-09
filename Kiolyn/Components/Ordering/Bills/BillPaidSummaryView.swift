//
//  BillPaidSummaryView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// Bill Paid view
class BillPaidSummaryView: KLView {
    let theme = Theme.mainTheme
    var disposeBag: DisposeBag?
    
    let paidInfo = NameValueView.name("Paid by ")
    let sep = KLLine()
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: theme.billViewWidth, height: theme.buttonHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        let pad = theme.guideline/2
        sep.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 1)
        paidInfo.frame = CGRect(x: pad, y: pad, width: frame.size.width - pad*2, height: frame.size.height - pad*2)
    }
    
    var billViewModel: BillViewModel? {
        didSet {
            // Disconnect old bindings Rebinding actions
            disposeBag = DisposeBag()
            
            guard let viewModel = billViewModel else { return }
            // Hide if not is paid
            isHidden = viewModel.bill.isNotPaid
            
            if viewModel.bill.paid {
                viewModel.transaction
                    .asDriver()
                    .filterNil()
                    .drive(onNext: { transaction in
                        self.paidInfo.name.text = "Paid by \(transaction.paidInfo)"
                        self.paidInfo.amount.text = transaction.totalWithTipAmount.asMoney
                    })
                    .disposed(by: disposeBag!)
            }
        }
    }
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        addSubview(sep)
        
        paidInfo.font = theme.normalFont
        addSubview(paidInfo)
    }
}

