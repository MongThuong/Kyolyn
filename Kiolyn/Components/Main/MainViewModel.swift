//
//  MainPageViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/17/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// View model for the Main View Controller
class MainViewModel: BaseViewModel {
    
    let openCloseShift = PublishSubject<Void>()
    let openShift = PublishSubject<Void>()
    let closeShift = PublishSubject<Shift>()
    
    /// Publish to open refund dialog.
    let refund = PublishSubject<Void>()
    /// Publish to open force dialog.
    let force = PublishSubject<Void>()
    /// Publish to send open cash drawer command to default printer.
    let openCashDrawer = PublishSubject<Void>()
    
    /// Publish to open navigation menu.
    let openNavigationMenu = PublishSubject<Void>()
    /// Publish to close navigation menu.
    let closeNavigationMenu = PublishSubject<Void>()
    
    /// Create with service provider
    ///
    /// - Parameter provider: Service provider.
    override init() {
        super.init()
        
        // Close navigation menu on any requests
        Observable
            .merge(SP.navigation.mainView.asObservable().mapToVoid(),
                   openCloseShift,
                   refund,
                   force,
                   openCashDrawer)
            .bind(to: closeNavigationMenu)
            .disposed(by: disposeBag)
        
        openCloseShift
            .withLatestFrom(dataService.activeShift)
            .filter { shift in shift == nil }
            .mapToVoid()
            .bind(to: openShift)
            .disposed(by: disposeBag)
        openCloseShift
            .withLatestFrom(dataService.activeShift)
            .filterNil()
            .bind(to: closeShift)
            .disposed(by: disposeBag)
        openShift
            .confirm("Do you want to open a new shift?")
            .mapToVoid()
            .progress("Opening new shift ...") {
                self.dataService.openNewShift()
            }
            .subscribe()
            .disposed(by: disposeBag)
        closeShift
            .confirm("Do you want to close current shift?")
            .mapToVoid()
            .progress("Checking unsettled trasactions and opening tables ...") {
                self.dataService.checkActiveShiftStatus()
            }
            .flatMap { status in self.shouldClose(shiftStatus: status) }
            .filter { shouldClose in shouldClose }
            .progress("Closing shift ...") { _ in
                self.dataService.closeActiveShift()
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        openCashDrawer
            .subscribe(onNext: { SP.printingService.openCashDrawer() })
            .disposed(by: disposeBag)
        
        refund
            .ensureCCDevice()
            .flatMap { ccDevice -> Single<(CCDevice, Double)?> in
                dmodal { RefundDVM() }.map { amount in
                    guard let amount = amount, amount > 0 else {
                        return nil
                    }
                    return (ccDevice, amount)
                }
            }
            .filterNil()
            .modal { (device, amount) in CreditRefundDVM(device, amount: amount) }
            .subscribe()
            .disposed(by: disposeBag)
        
        force
            .ensureCCDevice()
            .flatMap { ccDevice -> Single<(CCDevice, Double, String)?> in
                dmodal { ForceDVM() }.map { arg in
                    guard let (amount, authCode) = arg, amount > 0 else {
                        return nil
                    }
                    return (ccDevice, amount, authCode)
                }
            }
            .filterNil()
            .modal { (device, amount, authCode) in
                CreditForceDVM(device, amount: amount, authCode: authCode)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func shouldClose(shiftStatus status: ActiveShiftStatus) -> Single<Bool> {
        switch status {
        case .canClose:
            return Single.just(true)
        case .hasOpeningTables:
            return dmodal {
                MessageDVM("There are opening tables. Please choose one option below:",
                           type: .confirm,
                           yesText: "CLOSE SHIFT & MOVE\nthese tables to next shift",
                           noText: "CANCEL",
                           neutralText: "SHOW TABLES")
                }
                .map { res in
                    if res == .yes {
                        return true
                    }
                    if res == .neutral {
                        SP.navigation.mainView.accept(.tablesLayout)
                    }
                    return false
            }
        case .hasUnsettledTransactions:
            return dmodal {
                MessageDVM("Please settle all transactions before closing shift.",
                           type: .confirm,
                           yesText: "SHOW TRANSACTIONS",
                           noText: "CANCEL")
                }
                .map { res in
                    if res == .yes {
                        SP.navigation.mainView.accept(.transactions)
                    }
                    return false
            }
        default:
            return Single.just(false)
        }
    }
}

