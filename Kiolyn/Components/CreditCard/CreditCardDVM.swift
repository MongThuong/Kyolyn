//
//  CreditCardDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/26/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CreditCardDVM: DialogViewModel<Transaction> {
    /// The target device
    let device: BehaviorRelay<CCDevice>
    
    /// Display device info.
    let deviceInfo: Driver<String>
    
    /// True if need new trans number
    var requireNewTransNo: Bool { return false }
    var saveTransaction: Bool { return true }
    
    let status = BehaviorRelay<ViewStatus>(value: .none)
    let message = BehaviorRelay<String>(value: "")
    
    let approve = PublishSubject<Void>()
    let request = PublishSubject<Void>()
    
    let transaction = BehaviorRelay<Transaction?>(value: nil)
    
    override var dialogResult: Transaction? {
        return transaction.value
    }

    init(_ device: CCDevice) {
        self.device = BehaviorRelay(value: device)
        deviceInfo = self.device
            .asDriver()
            .map { device in
                if device.isStandalone {
                    return "\(device.name) (Standalone Terminal)"
                } else if device.isNoDevice {
                    return "NON-CARD"
                }
                let mac = device.macAddress.asMac
                let host = device.ipAddress.isEmpty ? mac : device.ipAddress
                return "\(device.name) (\(host):\(device.port))"
        }
        super.init()
        
        request
            .withLatestFrom(dataService.activeShift)
            .filterNil()
            .flatMapLatest { shift in
                self.sendRequest()
                    .catchError{ error -> Observable<CCStatus> in
                        Observable.just(CCStatus.error(error: error))
                    }
                    .map { status in (shift, status) }
            }
            .flatMap { (shift, ccStatus) -> Single<ViewStatus> in
                switch ccStatus {
                case let .progress(message):
                    self.device.accept(self.device.value) // Repeat to force update of device info
                    return Single.just(.message(m: message))
                case let .error(error):
                    return Single.just(.error(reason: error.localizedDescription))
                case let .completed(result):
                    guard result.isApproved else {
                        return Single.just(.error(reason: "[\(result.displayCode)] \(result.displayMessage)"))
                    }
                    let trans = try self.create(transaction: result, forShift: shift)
                    self.transaction.accept(trans)
                    // If no new trans no is required (void/adjust/close batch), then it's OK to stop here
                    guard self.requireNewTransNo else {
                        return self.dataService
                            .save(trans)
                            .map { _ in .ok }
                    }

                    return self.dataService
                        .increase(counter: ShiftCounter.transNo)
                        .catchError { error -> Single<Shift?> in
                            Single.just(self.dataService.activeShift.value)
                        }
                        .flatMap { shift -> Single<ViewStatus> in
                            trans.transNum = shift?.transNum ?? 0
                            return self.dataService
                                .save(trans)
                                .map { _ in .ok }
                    }
                }
            }
            .asDriver(onErrorJustReturn: ViewStatus.error(reason: "Unknown error."))
            .drive(status)
            .disposed(by: disposeBag)

        transaction
            .asDriver()
            .filterNil()
            .filter { trans in
                let auth = SP.authService
                if let printer = auth.defaultPrinter, let emp = auth.employee {
                    DispatchQueue.global(qos: .background).async {
                        _ = SP.printingService
                            .print(receipt: trans, byServer: emp, toPrinter: printer)
                            .subscribe()
                    }
                }
                return true
            }
            // Wait 3 seconds before closing the screen
            .delay(3)
            .drive(closeDialog)
            .disposed(by: disposeBag)

        if device.isNotStandalone {
            // If it is not a stand alone, we run the request immediately
            // otherwise user will choose Approve to proceed with request
            _ = dialogDidAppear.bind(to: request)
        }
    }
    
    func sendRequest() -> Observable<CCStatus> {
        fatalError("not implemented")
    }

    func create(transaction result: CCResult, forShift shift: Shift) throws -> Transaction {
        fatalError("not implemented")
    }
}
