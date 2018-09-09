//
//  StationManager.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/2/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum StationStatus {
    case disconnectedSub
    case connectedSub(main: String)
    case main(store: Store)
    case singleStation
    
    var isSub: Bool {
        switch self {
        case .disconnectedSub:
            return true
        case .connectedSub(_):
            return true
        default:
            return false
        }
    }
    
    var isMain: Bool { return !isSub }
    
    var canChangeState: Bool {
        switch self {
        case .connectedSub(_):
            return false
        default:
            return true
        }
    }
    
    var asString: String {
        switch self {
        case .disconnectedSub: return "[SUB] Disconnected"
        case let .connectedSub(main): return "[SUB] Connected to \(main)"
        case .main: return "[MAIN] \(Configuration.mainName):\(Configuration.mainPort)"
        case .singleStation: return "Single Station"
        }
    }
}

extension StationStatus: Equatable { }
func ==(lhs: StationStatus, rhs: StationStatus) -> Bool {
    switch (lhs, rhs) {
    case (let .connectedSub(main1), let .connectedSub(main2)):
        return main1 == main2
    case (.disconnectedSub, .disconnectedSub):
        return true
    case (.main, .main):
        return true
    case (.singleStation, .singleStation):
        return true
    default:
        return false
    }
}

class StationManager: NSObject {
    let disposeBag = DisposeBag()
    let status = BehaviorRelay<StationStatus>(value: .disconnectedSub)
    let mainStation = BehaviorRelay<(URL, String)?>(value: nil)
    
    var mainServiceBrowser: NetServiceBrowser? = nil
    var mainService: NetService? = nil

    var restServer: RestServer? = nil
    
    override init() {
        super.init()
        status
            .skip(1) // Skip the first initial value of BehaviorRelay
            .subscribe(onNext: { status in
                self.update(services: status)
            })
            .disposed(by: disposeBag)
        mainStation
            .asDriver()
            .skip(1) // Skip the first initial value of BehaviorRelay
            .map { main -> StationStatus? in
                guard self.status.value.isSub else {
                    return nil
                }
                guard let host = main?.0.host else {
                    SP.authService.signout()
                    return .disconnectedSub
                }
                return .connectedSub(main: host)
            }
            .filterNil()
            .drive(status)
            .disposed(by: disposeBag)
    }
    
    func update(services status: StationStatus) {
        i("[StationManager] Updating service for \(status)")
        switch status {
        case .singleStation:
            stopBrowingService()
            stopRestService()
        case let .main(store):
            stopBrowingService()
            start(restService: store)
        default:
            stopRestService()
            startBrowingService()
        }
    }
    
    private func startBrowingService() {
        guard mainServiceBrowser == nil else {
            return
        }
        mainServiceBrowser = NetServiceBrowser()
        mainServiceBrowser!.delegate = self
        mainServiceBrowser!.searchForServices(ofType: "_http._tcp.", inDomain: "local")
        i("[StationManager] Service Browser started")
    }
    
    private func stopBrowingService() {
        if let serviceBrowser = mainServiceBrowser {
            serviceBrowser.stop()
            i("[StationManager] Service Browser stopped")
        }
        mainServiceBrowser = nil
    }
    
    private func start(restService store: Store) {
        restServer = RestServer()
        // Start web service
        do {
            try restServer?.start(port: Configuration.mainPort)
            i("[StationManager] Rest Service started")
            // Start Bonjour
            mainService = NetService(domain: "local", type: "_http._tcp.", name: "\(Configuration.mainName):\(store.id)", port: Int32(Configuration.mainPort))
            mainService?.publish()
            i("[StationManager] Rest Service Bonjour published")
            // https://stackoverflow.com/questions/12661004/how-to-disable-enable-the-sleep-mode-programmatically-in-ios
            UIApplication.shared.isIdleTimerDisabled = true
        } catch {
            e("[StationManager] Could not start Rest Service \n\(error)")
            restServer = nil
        }
    }
    
    private func stopRestService() {
        UIApplication.shared.isIdleTimerDisabled = false
        if let restServer = restServer {
            restServer.stop()
            i("[StationManager] Rest Service stopped")
        }
        if let mainService = mainService {
            mainService.stop()
            i("[StationManager] Rest Service Bonjour stopped")
        }
    }
}

extension StationManager: NetServiceBrowserDelegate {
    /// If main service is found, normally there is no address yet, we need a further
    /// step to resolve the service address.
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        guard let _ = service.name.toServiceStoreID else {
            return
        }
        i("Resolving main service \(service.name)")
        service.delegate = self
        service.resolve(withTimeout: 10)
        mainService = service
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        // Make sure name is matched
        guard let _ = service.name.toServiceStoreID else {
            return
        }
        i("Main Station offline")
        mainStation.accept(nil)
    }
}

extension StationManager: NetServiceDelegate {
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        e("Could not resolve service \(sender.name)")
    }
    
    func netServiceDidResolveAddress(_ service: NetService) {
        guard let host = service.addresses?.first?.asNSIPAddress,
            let storeID = service.name.toServiceStoreID,
            let mainURL = URL(string: "http://\(host):\(service.port)") else {
                e("Could not resolve URL for \(service.name)")
                return
        }
        i("Found Main Station at \(mainURL)")
        mainStation.accept((mainURL, storeID))
    }
}

fileprivate extension String {    
    /// Check and return main service storeID
    var toServiceStoreID: String? {
        let components = self.components(separatedBy: ":")
        guard components.count == 2 else {
            return nil
        }
        let name = components[0]
        let storeID = components[1]
        guard name == Configuration.mainName, storeID.isNotEmpty else {
            return nil
        }
        return storeID
    }
}

fileprivate extension Data {
    /// Convert Data to NetService IP Address
    var asNSIPAddress: String? {
        return self.withUnsafeBytes { (p: UnsafePointer<sockaddr>) -> String? in
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(p, socklen_t(self.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return nil
            }
            return String(cString: hostname)
        }
    }
}
