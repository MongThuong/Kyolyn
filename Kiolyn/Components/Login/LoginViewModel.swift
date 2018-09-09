//
//  LoginPageViewModel.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/16/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import Fabric
import SwiftyUserDefaults

// MARK: - Keys used for storing in user default
extension UserDefaults {
    static let lastStoreID = DefaultsKey<String?>("lastStoreID")
    static let stationID = DefaultsKey<String?>("stationID")
    static let lastUpdated = DefaultsKey<Date?>("lastUpdated")
    static let lastSettingsAreaScale = DefaultsKey<Int>("lastSettingsAreaScale")
    static let lastTablesLayoutScale = DefaultsKey<Int>("lastTablesLayoutScale")
}

/// Login screen logic.
class LoginViewModel: ViewModel {
    
    /// The view status that will control show/hide of loading indicator and error message.
    var viewStatus = BehaviorRelay<ViewStatus>(value: ViewStatus.none)
    
    let storeID = BehaviorRelay<String>(value: Defaults[UserDefaults.lastStoreID] ?? "")
    
    let store = BehaviorRelay<Store?>(value: nil)
    let station = BehaviorRelay<Station?>(value: nil)
    let passkey = BehaviorRelay<String>(value: "")
    
    var canRemoteSync: Driver<Bool>!
    let remoteSync = PublishSubject<Void>()
    var canSignin: Driver<Bool>!
    let signin = PublishSubject<Void>()
    
    /// Name of the store
    var canClockin: Driver<Bool>!
    /// To clockin
    let clockin = PublishSubject<Void>()
    
    /// Name of the store
    var canClockout: Driver<Bool>!
    /// For clockout
    let clockout = PublishSubject<Reason?>()
    
    /// Return the application version for displaying at the bottom. This version is used for logging bug.
    var version: String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            return ""
        }
        return version
    }
    /// IP Adress of the running device
    var ipAddress: String {
        return Network.getIFAddresses().first ?? ""
    }
    /// Return station ID in shorten form of device vendor ID
    var stationID: String {
        var stationID = Defaults[UserDefaults.stationID] ?? ""
        if stationID.isEmpty {
            let deviceID = UIDevice.current.identifierForVendor ?? UUID()
            stationID = deviceID.compressedUUIDString.uppercased()
            Defaults[UserDefaults.stationID] = stationID
        }
        return stationID
    }
    /// Last updated
    var lastUpdated: Driver<String>!
    
    /// Create with service provider
    ///
    /// - Parameter provider: Service provider.
    override init() {
        super.init()
        
        // Change of storeID should trigger refreshing state
        storeID
            .flatMap { storeID in self.update(state: storeID) }
            .subscribe()
            .disposed(by: disposeBag)
        
        lastUpdated = UserDefaults.standard.rx
            .observe(Date.self, UserDefaults.lastUpdated._key)
            .map { "Last Updated: \($0?.toString("MMM d HH:mm") ?? "")" }
            .asDriver(onErrorJustReturn: "")
        
        
        // MARK: - Remote Sync
        canRemoteSync = Driver
            .combineLatest(
                storeID.asDriver().distinctUntilChanged(),
                passkey.asDriver().distinctUntilChanged(),
                viewStatus.asDriver().distinctUntilChanged(),
                SP.stationManager.status.asDriver().distinctUntilChanged())
            { (storeID, passkey, viewStatus, stationStatus) -> Bool in
                return storeID.count >= 12 /*&& mac.isNotEmpty*/ && passkey.isNotEmpty && !viewStatus.isLoading && stationStatus.canChangeState
        }
        remoteSync
            .withLatestFrom(viewStatus)
            .filter { status in status.isNotLoading }
            .subscribe(onNext: { _ in
                _ = SP.database
                    .sync(remote: self.storeID.value, passkey: self.passkey.value, mac: self.stationID)
                    .subscribe { event in
                        switch event {
                        case let .next(progress):
                            self.viewStatus.accept(.progress(p: progress))
                        case let .error(error):
                            self.viewStatus.accept(.error(reason: error.localizedDescription))
                        case .completed:
                            self.viewStatus.accept(.ok)
                            Defaults[UserDefaults.lastUpdated] = Date()
                            // Update state after a successful syncing
                            _ = self.update(state: self.storeID.value).subscribe()
                        }
                }
            })
            .disposed(by: disposeBag)
        
        // MARK: - Signin
        canSignin = Driver
            .combineLatest(
                store.asDriver(),
                station.asDriver(),
                passkey.asDriver(),
                viewStatus.asDriver()) { (store, station, passkey, viewStatus) in
                    return store != nil && station != nil && passkey.isNotEmpty && viewStatus.isNotLoading
        }
        signin
            .withLatestFrom(viewStatus)
            .filter { $0.isNotLoading }
            .flatMap { _ -> Single<ViewStatus> in
                guard let store = self.store.value, let station = self.station.value else {
                    return Single.just(.error(reason: "Store and Station are not available"))
                }
                if SP.stationManager.status.value.isMain {
                    return SP.authService.signin(store, station: station, withPasskey: self.passkey.value)
                        .map { _ in ViewStatus.ok }
                        .catchError { error -> Single<ViewStatus> in
                            Single.just(.error(reason: error.localizedDescription))
                    }
                } else {
                    return SP.restClient
                        .verify(signin: store, station: station, passkey: self.passkey.value)
                        .map { id -> ViewStatus in
                            guard let id = id else {
                                return .error(reason: "Could not login with Main. Please make sure passkey is correct and connection to Main is good.")
                            }
                            // Signin using the id returned from server
                            SP.authService.signin(id: id)
                            return .ok
                    }
                }
            }
            .asDriver(onErrorJustReturn: .error(reason: "Unknown error"))
            .drive(viewStatus)
            .disposed(by: disposeBag)
        
        canClockin = Driver
            .combineLatest(
                store.asDriver(),
                station.asDriver(),
                passkey.asDriver(),
                viewStatus.asDriver()) { (store, station, passkey, viewStatus) -> Bool in
                    return store != nil && station != nil && station!.main && passkey.isNotEmpty && viewStatus.isNotLoading
        }
        clockin
            .withLatestFrom(viewStatus)
            .filter { $0.isNotLoading }
            .flatMap { _ -> Single<(MessageDT, String)> in
                SP.timecard
                    .clockin(store: self.store.value!, forEmployee: self.passkey.value)
                    .map { res in (.info, "\(res.0.name) has clocked-in at \(res.1.createdTime.toString("HH:mm")).") }
                    .catchError { error in Single<(MessageDT, String)>.just((.error, error.localizedDescription)) }
            }
            .showMessage()
            .disposed(by: disposeBag)
        
        canClockout = Driver
            .combineLatest(
                store.asDriver(),
                station.asDriver(),
                passkey.asDriver(),
                viewStatus.asDriver()) { (store, station, passkey, viewStatus) -> Bool in
                    return store != nil && station != nil && station!.main && passkey.isNotEmpty && viewStatus.isNotLoading
        }
        clockout
            .withLatestFrom(viewStatus)
            .filter { $0.isNotLoading }
            .flatMap { _ in
                // We need to perform this with nil reason to make sure the condition
                // of clocking out is checked before asking for a reason.
                SP.timecard.canClockout(store: self.store.value!, forEmployee: self.passkey.value)
            }
            .filter { error in
                if let error = error {
                    derror(error.localizedDescription)
                    return false
                }
                return true
            }
            // If OK, then show the select reason dialog
            .modal { _ in SelectClockoutReasonDVM(forStore: self.store.value!) }
            .flatMap { reason -> Single<(MessageDT, String)> in
                SP.timecard
                    .clockout(store: self.store.value!, forEmployee: self.passkey.value, withReason: reason)
                    .map { res in (.info, "\(res.0.name) has clocked-out at \(res.1.createdTime.toString("HH:mm")).") }
                    .catchError { error in Single<(MessageDT, String)>.just((.error, error.localizedDescription)) }
            }
            .showMessage()
            .disposed(by: disposeBag)
        
        if !Configuration.standalone {
            SP.stationManager.mainStation
                .skip(1)
                .flatMap { main in self.update(sub: main?.1) }
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    /// Update when in sub mode.
    ///
    /// - Parameter storeID: the returned Main storeID
    private func update(sub storeID: String?) -> Single<()> {
        guard let storeID = storeID, storeID.isNotEmpty else {
            self.store.accept(nil)
            self.station.accept(nil)
            return Single.just(())
        }
        let restClient = SP.restClient
        return restClient.load(store: storeID)
            .flatMap { store -> Single<(Store?, Station?)> in
                guard let store = store else {
                    derror("Could not load Store from Main, please make sure this device can connect to Main for getting data.")
                    return Single.just((nil, nil))
                }
                return restClient.load(station: store.id, byMacAddress: self.stationID)
                    .map { station in (store, station) }
            }
            .map { args in
                let (store, station) = args
                self.store.accept(store)
                self.station.accept(station)
        }
    }
    
    /// Update state based on new input storeID, mac.
    ///
    /// - Parameters:
    ///   - storeID: The new input storeID.
    private func update(state storeID: String) -> Single<()> {
        v("[LOGIN] Updating state \(storeID)")
        let db = SP.database
        return db
            .async { () -> (Store?, Station?) in
                guard storeID.count >= 12 else {
                    // Invalid storeID - clear stored values
                    return (nil, nil)
                }
                // we need to reload if from database
                guard let updatedStore: Store = db.load(storeID) else {
                    // ... new store could not be loaded, clear stored values
                    return (nil, nil)
                }
                // Save it for later usage
                Defaults[UserDefaults.lastStoreID] = storeID
                // No mac address, or
                guard storeID.isNotEmpty,
                    // ... could not load station using storeID and mac address
                    let updatedStation: Station = db.load(station: storeID, byMacAddress: self.stationID) else {
                        // ... clear station
                        return (updatedStore, nil)
                }
                // ... otherwise update with new station
                return (updatedStore, updatedStation)
            }
            .map { storeStation in
                let (store, station) = storeStation
                self.store.accept(store)
                self.station.accept(station)

                // Update status
                var status: StationStatus = .disconnectedSub
                if Configuration.standalone {
                    status = .singleStation
                } else if let store = store, let station = station {
                    status = station.main ? .main(store: store): .disconnectedSub
                }
                SP.stationManager.status.accept(status)
        }
    }
}
