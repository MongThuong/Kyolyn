//
//  BillActionsView.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/9/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// Bill actions
class BillActionsView: KLView {
    let theme = Theme.mainTheme
    var disposeBag: DisposeBag?
    
    let print = KLPrimaryRaisedButton()
    let reprint = KLPrimaryRaisedButton()
    let pay = KLPrimaryRaisedButton()
    let void = KLWarnFlatButton()
    let printCheck = KLPrimaryFlatButton()
    let printReceipt = KLPrimaryFlatButton()
    let sep = KLLine()
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    /// The bill view model.
    var billViewModel: BillViewModel? = nil {
        didSet {
            // Disconnect old bindings Rebinding actions
            disposeBag = DisposeBag()
            
            defer {
                invalidateIntrinsicContentSize()
                layoutIfNeeded()
            }
            
            // Make sure we got something
            guard let viewModel = billViewModel else {
                reprint.isEnabled = false
                print.isEnabled = false
                pay.isEnabled = false
                void.isEnabled = false
                printCheck.isEnabled = false
                printReceipt.isEnabled = false
                return
            }
            
            let bill = viewModel.bill
            // Button statuses
            reprint.isHidden = bill.paid || !bill.printed
            print.isHidden = bill.paid || bill.printed
            pay.isHidden = bill.paid
            void.isHidden = bill.isNotPaid
            printCheck.isHidden = bill.isNotPaid
            printReceipt.isHidden = bill.isNotPaid
            
            // Update button status based on the moving bill
            viewModel.billList.movingBill
                .asDriver()
                .drive(onNext: { movingBill in
                    if let _ = movingBill {
                        self.pay.isEnabled = false
                        self.print.isEnabled = false
                        self.printCheck.isEnabled = false
                        self.printReceipt.isEnabled = false
                        self.void.isEnabled = false
                    } else {
                        self.pay.isEnabled = bill.payable
                        self.print.isEnabled = bill.payable
                        self.printCheck.isEnabled = true
                        self.printReceipt.isEnabled = true
                        self.void.isEnabled = true
                    }
                })
                .disposed(by: disposeBag!)
            
            pay.rx.tap.bind(to: viewModel.pay).disposed(by: disposeBag!)
            print.rx.tap.bind(to: viewModel.print).disposed(by: disposeBag!)
            reprint.rx.tap.bind(to: viewModel.print).disposed(by: disposeBag!)
            printCheck.rx.tap.bind(to: viewModel.printCheck).disposed(by: disposeBag!)
            printReceipt.rx.tap.bind(to: viewModel.printReceipt).disposed(by: disposeBag!)
            void.rx.tap.bind(to: viewModel.void).disposed(by: disposeBag!)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return billViewModel?.bill.paid ?? false
            ? CGSize(width: theme.billViewWidth, height: theme.normalButtonHeight*2)
            : CGSize(width: theme.billViewWidth, height: theme.normalButtonHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        let w = frame.size.width
        let h = frame.size.height
        let p = theme.guideline/2
        sep.frame = CGRect(x: 0, y: 0, width: w, height: 1)
        let paid = billViewModel?.bill.paid ?? false
        if paid {
            void.frame = CGRect(x: 0, y: 0, width: w, height: h/2)
            printCheck.frame = CGRect(x: 0, y: h/2, width: w/2, height: h/2)
            printReceipt.frame = CGRect(x: w/2, y: h/2, width: w/2, height: h/2)
        } else {
            print.frame = CGRect(x: p, y: p, width: (w - p*3)/2, height: h - p*2)
            reprint.frame = CGRect(x: p, y: p, width: (w - p*3)/2, height: h - p*2)
            pay.frame = CGRect(x: w/2 + p/2, y: p, width: (w - p*3)/2, height: h - p*2)
        }
    }
    
    override func prepare() {
        super.prepare()
        addSubview(sep)
        reprint.titleColor = theme.warn.base
        reprint.set(icon: FAKFontAwesome.checkIcon(withSize: 20.0), withText: "PRINT")
        addSubview(reprint)
        print.titleColor = theme.textColor
        print.title = "PRINT"
        addSubview(print)
        pay.title = "PAY"
        addSubview(pay)
        void.titleColor = theme.warn.base
        void.set(icon: FAKFontAwesome.banIcon(withSize: 24), withText: "Click Here to Void")
        void.isHidden = true
        addSubview(void)
        printCheck.titleColor = theme.secondary.base
        printCheck.set(icon: FAKFontAwesome.printIcon(withSize: 24), withText: "CHECK")
        printCheck.isHidden = true
        addSubview(printCheck)
        printReceipt.titleColor = theme.secondary.base
        printReceipt.set(icon: FAKFontAwesome.printIcon(withSize: 24), withText: "RECEIPT")
        printReceipt.isHidden = true
        addSubview(printReceipt)
    }
}

