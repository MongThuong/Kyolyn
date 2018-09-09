//
//  PrintItemsDialog.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/17/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Material

/// General printing dialog
class PrintDialog<PJ: PrintingJob, DR>: KLDialog<DR> {
    
    /// The printing jobs table view.
    let jobs = KLTableView()
    /// For skipping the printing.
    let skip = FlatButton()

    /// The view model
    private var viewModel: PrintDVM<PJ, DR>
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ vm: DialogViewModel<DR>) {
        guard let vm = vm as? PrintDVM<PJ, DR> else {
            fatalError("Expecting PrintDVM<PJ, DR>")
        }
        self.viewModel = vm
        super.init(vm)
    }
    
    override func makeDialogContentView() -> UIView? {
        jobs.rowHeight = theme.largeButtonHeight
        jobs.register(PrintingJobTableViewCell.self, forCellReuseIdentifier: "Cell")
        return jobs
    }
    
    override func makeDialogBottomBar() -> Bar? {
        guard viewModel.allowSkipping else {
            return nil
        }
        let bar = Bar()
        skip.titleLabel?.font = theme.normalFont
        skip.title = "SKIP PRINTING"
        skip.titleColor = theme.warn.base
        bar.rightViews = [skip]        
        skip.rx.tap.bind(to: viewModel.skip).disposed(by: disposeBag)
        return bar
    }
    
    override func prepare() {
        super.prepare()
        
        viewModel.jobs
            .asDriver()
            .drive(jobs.rx.items) { (tableView, row, job) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PrintingJobTableViewCell
                cell.disposeBag = DisposeBag()
                cell.name.text = job.printer.name
                job.status
                    .asDriver()
                    .drive(cell.rx.status)
                    .disposed(by: cell.disposeBag!)
                return cell
            }
            .disposed(by: disposeBag)
        
        jobs.rx.modelSelected(PJ.self)
            .asDriver()
            .drive(viewModel.print)
            .disposed(by: disposeBag)
    }
}

class PrintItemsDialog: PrintDialog<ItemsPrintingJob, PrintItemsDR> {}
class PrintBillDialog: PrintDialog<PrintingJob, PrintBillDR> {}
class PrintSingleDialog: PrintDialog<PrintingJob, Void> { }

