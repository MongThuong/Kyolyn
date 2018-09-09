//
//  BillsController.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/28/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material
import FontAwesomeKit

/// For handling bills.
class BillsController: UIViewController {
    private let theme =  Theme.mainTheme
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let bar = KLBar()
    private let reset = KLWarnRaisedButton()
    private let add = KLPrimaryRaisedButton()
    private let print = KLPrimaryRaisedButton()
    
    private let movingMessage = UILabel()
    private let clear =  KLWarnRaisedButton()
    
    private let viewModel = BillsViewModel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = theme.cardBackgroundColor
        
        reset.fakIcon = FAKFontAwesome.trashIcon(withSize: 18)
        add.fakIcon = FAKFontAwesome.plusIcon(withSize: 18)
        print.fakIcon = FAKFontAwesome.printIcon(withSize: 18)
        
        clear.title = "CLEAR"
        
        movingMessage.font = theme.normalFont
        movingMessage.textColor = theme.textColor
        
        bar.backgroundColor = .clear
        bar.leftViews = [reset, add, print]
        bar.rightViews = [movingMessage, clear]
        view.addSubview(bar)
        bar.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(theme.normalButtonHeight)
        }
        
        scrollView.delegate = self
        scrollView.bounces = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.width.bottom.centerX.equalToSuperview()
            make.top.equalTo(bar.snp.bottom)
        }
        
        Driver
            .combineLatest(
                viewModel.orderManager.order.asDriver(),
                viewModel.movingBill.asDriver()) { ($0, $1) }
            .drive(onNext: { (order, movingBill) in
                self.reset.isEnabled = false
                self.add.isEnabled = false
                self.print.isEnabled = false
                guard let order = order else {
                    return
                }
                guard movingBill == nil else {
                    self.add.isEnabled = true
                    return
                }
                self.reset.isEnabled = order.isNotClosed && order.unpaidBills.isNotEmpty
                self.add.isEnabled = order.isNotClosed
                self.print.isEnabled = order.bills.isNotEmpty
            })
            .disposed(by: disposeBag)

        reset.rx.tap
            .bind(to: viewModel.reset)
            .disposed(by: disposeBag)
        add.rx.tap
            .bind(to: viewModel.addBill)
            .disposed(by: disposeBag)
        print.rx.tap
            .bind(to: viewModel.printAll)
            .disposed(by: disposeBag)

        // Update on bills changed and just after subviews is laid out
        Observable
            .combineLatest(
                // Need to wait for view to layout properly
                rx.viewDidLayoutSubviews,
                viewModel.bills.asObservable()
            ) { _, bills in bills }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { self.update(bills: $0) })
            .disposed(by: disposeBag)

        // Clear the moving mode
        clear.rx.tap
            .map { _ -> Bill? in nil }
            .bind(to: viewModel.movingBill)
            .disposed(by: disposeBag)

        // Update layout upon moving mode changed
        viewModel.movingBill
            .asDriver()
            .drive(onNext: { bill in
                UIView.animate(withDuration: 0.2, animations: {
                    guard let bill = bill else {
                        self.movingMessage.text = ""
                        self.movingMessage.isHidden = true
                        self.clear.isHidden = true
                        return
                    }

                    self.movingMessage.text = "\(UInt(bill.quantity)) selected"
                    self.movingMessage.sizeToFit()
                    self.movingMessage.isHidden = false
                    self.clear.isHidden = false

                    self.bar.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
   
    // Cached bill views
    private var billViews: [BillView] {
        return self.scrollView.subviews
            .map { $0 as? BillView }
            .filter { $0 != nil }
            .map { $0! }
    }
    
    private func billView(at index: Int) -> BillView {
        let scrollHeight = scrollView.frame.height
        let padding = theme.guideline/2
        let billHeight = scrollHeight - padding * 2
        let billWidth = theme.billViewWidth
        let frame = CGRect(x: padding + (padding + billWidth) * CGFloat(index), y: padding, width: billWidth, height: billHeight)
        if index < billViews.count {
            let billView = billViews[index]
            billView.frame = frame
            return billView
        } else {
            let billView = BillView(frame: frame)
            scrollView.addSubview(billView)
            return billView
        }
    }
    
    private func update(bills: [BillViewModel]) {
        // Hide all bills first
        for v in billViews {
            v.isHidden = true
        }
        // add view and make constraints
        for (index, vm) in bills.enumerated() {
            let billView = self.billView(at: index)
            billView.isHidden = false
            billView.billViewModel = vm
            billView.billIndex = index + 1
        }
        // update size
        let scrollHeight = scrollView.frame.height
        let padding = theme.guideline/2
        let billWidth = theme.billViewWidth
        scrollView.contentSize = CGSize(width: padding * 2 + (billWidth + padding) * CGFloat(bills.count), height: scrollHeight)
    }
}

extension BillsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: false)	
    }
}
