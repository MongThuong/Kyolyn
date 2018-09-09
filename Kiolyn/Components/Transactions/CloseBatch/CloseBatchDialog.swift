//
//  CloseBatchDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 10/14/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// For closing batch.
class CloseBatchDialog: KLDialog<Void> {
    private let jobsTableView = KLTableView()
    private let settleButton = KLFlatButton()
    
    private var viewModel: CloseBatchDVM

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<Void>) {
        guard let vm = vm as? CloseBatchDVM else {
            fatalError("Expecting CloseBatchDVM")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override func makeDialogContentView() -> UIView? {
        jobsTableView.rowHeight = theme.largeButtonHeight
        jobsTableView.register(CloseBatchJobTableViewCell.self, forCellReuseIdentifier: "Cell")
        return jobsTableView
    }

    override func makeDialogBottomBar() -> Bar? {
        let bar = Bar()
        settleButton.titleLabel?.font = theme.normalFont
        settleButton.title = "MARK AS SETTLED"
        settleButton.titleColor = theme.warn.base
        bar.rightViews = [settleButton]
        settleButton.rx.tap.bind(to: viewModel.settle).disposed(by: disposeBag)
        return bar
    }
    
    override func prepare() {
        super.prepare()
        
        viewModel.jobs
            .asDriver()
            .drive(jobsTableView.rx.items) { (tableView, row, job) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CloseBatchJobTableViewCell
                cell.job = job
                
                return cell
            }
            .disposed(by: disposeBag)

        jobsTableView.rx.modelSelected(CloseBatchJob.self)
            .asDriver()
            .filter { job in job.status.value.isNotOK && job.status.value.isNotLoading }
            .drive(viewModel.request)
            .disposed(by: disposeBag)
        
        viewModel.jobsChanged
            .asDriver(onErrorJustReturn: ())
            .map { _ in self.viewModel.jobs.value.all { $0.status.value.isNotLoading } }
            .drive(dialogCloseButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.jobsChanged
            .asDriver(onErrorJustReturn: ())
            .map { _ in self.viewModel.jobs.value.any { $0.status.value.isError } }
            .drive(settleButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

