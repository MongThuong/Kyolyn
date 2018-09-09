	//
//  Database+RemoteSync.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import RxSwift

/// Represents the result of getting Sync Session from API services. This object must conform to `Mappable` from `ObjectMapper` in order to be deserialzed from a JSON result. The JSON result might be in 2 cases:
/// - Error: There will only be `code` and `message`.
/// - Success: There will be a `[String: Any]` properties that represents a `Store`.
class SyncSessionResponse : Mappable {
    /// The error code returned from server.
    var type: String?
    /// The error message returned from server.
    var data: String?
    /// The `Store` object returned from server.
    var store: Store?
    var syncSession: SyncSession?
    required init?(map: Map) { }
    func mapping(map: Map) {
        type <- map["type"]
        data <- map["data"]
        store <- map["store"]
        syncSession <- map["session"]
    }
}

/// Contain remote sync notifications.
extension Notification.Name {
    /// Hook to get notified about remote progress sync error.
    static let klRemoteSyncError = Notification.Name("klRemoteSyncError")
    /// Hook to get notified about remote progress sync changed.
    static let klRemoteSyncProgressChanged = Notification.Name("klRemoteSyncProgressChanged")
    /// Hook to get notified about remote sync completed.
    static let klRemoteSyncCompleted = Notification.Name("klRemoteSyncCompleted")
}

/// Contain all the Remote Sync Error.
enum RemoteSyncError : LocalizedError {
    /// Could not get a sync session from API server
    case couldNotGetSyncSession(message: String)
    /// Something is wrong with the configuration
    case badConfiguration
    /// Something is wrong with the configuration
    case missingSyncSession
    /// The given store is not a good one for syncing
    case invalidSyncSession(message: String)
    /// User friendly description
    var errorDescription: String? {
        switch self {
        case let .couldNotGetSyncSession(message):
            return "\(message)."
        case .badConfiguration:
            return "Bad configuration."
        case .missingSyncSession:
            return "Missing sync session."
        case let .invalidSyncSession(message):
            return "\(message)."
        }
    }
}

/// Contains all the logic relating to Remote Sync, including
///
/// # Sync Session API
/// # Remote Sync controlling
/// # Remote Sync Notification
extension CouchbaseDatabase {
    func sync(remote storeID: String, passkey: String, mac: String) -> Observable<Double> {
        return sync(remote: storeID, passkey: passkey, mac: mac, apiURL: Configuration.apiRootURL, syncURL: Configuration.syncRootURL)
    }
    func sync(remote storeID: String, passkey: String, mac: String, apiURL: String = Configuration.apiRootURL, syncURL: String = Configuration.syncRootURL) -> Observable<Double> {
        return Observable.create { observer -> Disposable in
            observer.onNext(0) // Mark as loading
            _ = self.get(syncSession: apiURL, store: storeID, passkey: passkey, mac: mac)
                .subscribe { event in
                    switch event {
                    case let .error(error):
                        e("Error syncing with remote server.\n\(error.localizedDescription)")
                        observer.onError(error)
                    case let .success(store):
                        // got some store properties to save, now save it as a Store
                        do {
                            try self.save(store)
                        } catch {
                            // Log and inform error
                            e("Could not save synced Store \(error.localizedDescription)")
                            observer.onError(error)
                        }
                        // Now do the sync work and wire its values to the observers
                        _ = self.sync(remote: syncURL, for: store).bind(to: observer)
                    }
                }
            return Disposables.create()
        }
    }

    /// Call API server for a Sync Session with the Sync Gateway, given parameters will be validated against the Store' settings on the server either or not returning a good Sync Session. Sync token is returned only when:
    /// 1. Store is valid (its Merchant is in active state or trial period is still valid).
    /// 2. Passkey must point to the user with Order permission.
    /// 3. Given mac must be registered as Main Station.
    ///
    /// - Parameters:
    ///   - apiRootURL: The API root URL, default to whatever inside the apiRootURL.
    ///   - storeID: The `id` of the `Store`.
    ///   - passkey: The `passkey` that will be used to identified the current user.
    ///   - mac: The `mac` address of the running iPad.
    /// - Returns: An `Observable` of `[String: Any]` which contain `Store` properties which contains sync session information under key of `sync_session`.
    private func get(syncSession apiURL: String, store storeID: String, passkey: String, mac: String) -> Single<Store> {
        // Make sure inputs are good
        guard apiURL.isNotEmpty, storeID.isNotEmpty, passkey.isNotEmpty, mac.isNotEmpty else {
            return Single.error(RemoteSyncError.couldNotGetSyncSession(message: "Invalid inputs."))
        }
        return Single.create { single in
            // Prepare POST data
            let data: Parameters = [
                "storeid": storeID,
                "passkey": passkey,
                "mac_address": mac
            ]
            // Call server
            Alamofire.request("\(apiURL)/v2/session", method: .post, parameters: data, encoding: JSONEncoding.default)
                .log()
                .responseObject { (response: DataResponse<SyncSessionResponse>) in
                    // Analyze the content
                    switch response.result {
                    case .success:
                        // Make sure good response
                        guard let value = response.result.value else {
                            // Reject with given error detail
                            return single(.error(RemoteSyncError.couldNotGetSyncSession(message: "Empty response")))
                        }
                        // If there is an error code then it's a fail
                        if let data = value.data {
                            // Reject with given error detail
                            return single(.error(RemoteSyncError.couldNotGetSyncSession(message: data)))
                        }
                        // Verify Store
                        guard let store = value.store else {
                            return single(.error(RemoteSyncError.invalidSyncSession(message: "Empty Store")))
                        }
                        store.type = Store.documentType
                        store.channels = ["local_\(store.id)"]
                        
                        // Verify session
                        guard let session = value.syncSession else {
                            return single(.error(RemoteSyncError.invalidSyncSession(message: "Empty Session")))
                        }
                        // Verify session id
                        guard session.isValid else {
                            return single(.error(RemoteSyncError.invalidSyncSession(message: "Invalid or expired session")))
                        }
                        v("SYNC-SESSION: \(session)")
                        store.syncSession = session
                        single(.success(store))
                    case let .failure(error):
                        single(.error(RemoteSyncError.couldNotGetSyncSession(message: "\(error.localizedDescription)")))
                    }
            }
            return Disposables.create()
        }
    }

    /// Start a remote syncing process for a given store.
    ///
    /// - Parameters:
    ///   - syncURL: The sync gateway root URL, default to whatever inside the syncRootURL.
    ///   - store: The `Store` to sync with.
    /// - Returns: An `Observable` of syncing progress.
    private func sync(remote syncURL: String, for store: Store) -> Observable<Double> {
        // Make sure url is set
        guard !syncURL.isEmpty, let url = URL(string: syncURL) else {
            return Observable.error(RemoteSyncError.badConfiguration)
        }
        // Make sure the store contains a session
        guard let session = store.syncSession else {
            return Observable.error(RemoteSyncError.missingSyncSession)
        }
        // Make sure store is good
        guard session.isValid else {
            return Observable.error(RemoteSyncError.invalidSyncSession(message: "Invalid or expired sync session"))
        }
        // Configure sync callback
        return Observable<Double>.create { observer -> Disposable in
            // Create pull/push
            let pull = self.database.createPullReplication(url)
            // Set the session cookie to sync
            pull.setCookieNamed(session.cookieName, withValue: session.sessionID, path: "/", expirationDate: session.expires, secure: false)
            pull.continuous = false
            // We need to sync channels with either storeId (mostly menu/settings) and timecard data
            pull.channels = [store.id, "etc_\(store.id)"]
            // Configure the push
            let push = self.database.createPushReplication(url)
            push.setCookieNamed(session.cookieName, withValue: session.sessionID, path: "/", expirationDate: session.expires, secure: false)
            push.continuous = false
            push.filter = "remotePushFilter"
            push.filterParams = ["storeid": store.id]
            var disposableBag: DisposeBag? = DisposeBag()
            Observable.merge(
                NotificationCenter.default.rx.notification(.cblReplicationChange, object: pull).skip(1),
                NotificationCenter.default.rx.notification(.cblReplicationChange, object: push).skip(1))
                .subscribe(onNext: { _ in
                    v("[REMOTESYNC] Pull Status \(pull.status.rawValue) /  Push Status \(pull.status.rawValue)")
                    // HACK: nowhere on the Interner tell the reason why the 2 replications always start with offline statuses
                    if pull.status == .offline && push.status == .offline {
                        observer.onNext(0)
                        return
                    }
                    // Still active, calculate and inform progress
                    if pull.status == .active || push.status == .active {
                        let total = pull.changesCount + push.changesCount
                        let completed = pull.completedChangesCount + push.completedChangesCount
                        if total > 0 {
                            let progress = Double(completed) / Double(total)
                            v("[REMOTESYNC] Progress changed \(progress)")
                            observer.onNext(progress)
                        } else {
                            observer.onNext(0)
                        }
                    } else { // All inactive, means done
                        i("[REMOTESYNC] Completed")
                        // Notify listener
                        observer.onCompleted()
                        disposableBag = nil
                    }
                }).disposed(by: disposableBag!)
            
            // Start the replications
            pull.start()
            push.start()
            i("[REMOTESYNC] Started for Store '\(store.storeName)/\(store.id)'")

            // When disposed, it must stop the replications
            return Disposables.create {
                pull.stop()
                push.stop()
                disposableBag = nil
            }
        }
    }
}
