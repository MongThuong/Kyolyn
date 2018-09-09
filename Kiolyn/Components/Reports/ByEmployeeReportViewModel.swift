//
//  ServerReportViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/16/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Employee Report.
class ByEmployeeReportViewModel: TableReportViewModel<EmployeeTotalReportRow> {

    // Server filter
    let allServer: String = ""
    let servers = BehaviorRelay<[(String, String)]>(value: [])
    let selectedServer = BehaviorRelay<String>(value: "")
    
    override init() {
        super.init()
        
        selectedServer
            .asDriver()
            .filter { _ in self.shouldReload }
            .distinctUntilChanged()
            .map { _ -> Void in self.calculateDateFilterValues = false }
            .drive(reload)
            .disposed(by: disposeBag)
    }
    
    override func loadData() -> Single<ReportQueryResult<EmployeeTotalReportRow>> {
        let storeID = self.store.id
        let db = SP.database
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value
        let employee = selectedServer.value
        if employee.isEmpty {
            return db.async {
                db.load(byEmployeeReport: storeID, fromDate: fdate, toDate: tdate, shift: shift)
            }
        } else {
            let page = self.page.value
            let pageSize = self.pageSize.value
            return db.async {
                let ordersQR = db.load(orders: storeID, ofEmployee: employee, fromDate: fdate, toDate: tdate, shift: shift, page: page, pageSize: pageSize)
                // Map to required result
                return ReportQueryResult(
                    rows: ordersQR.rows.map { order in order.employeeReportRow },
                    summary: ReportQuerySummary(JSON: ordersQR.summary.toJSON())!)
            }
        }
    }
    
    override func update(filter summary: ReportQuerySummary) {
        super.update(filter: summary)
        servers.accept([("ALL", self.allServer)] +
            summary.servers.map { id -> (String, String) in
                let db = SP.database
                guard let server: Employee = db.load(id) else {
                    return ("NOT FOUND", id)
                }
                return (server.name.uppercased(), id)
        })
        selectedServer.accept(servers.value.first!.1)
    }
    
    override func doPrint(to printer: Printer) -> PrimitiveSequence<SingleTrait, Void> {
        let (fdate, tdate) = selectedDate.value
        let shift = selectedShift.value
        let employee = selectedServer.value
        return SP.printingService.print(byServerReport: store, fromDate: fdate, toDate: tdate, shift: shift, employee: employee, toPrinter: printer)
    }
}

fileprivate extension Order {
    var employeeReportRow: EmployeeTotalReportRow {
        let row = EmployeeTotalReportRow()
        row.order = self
        return row
    }
}
