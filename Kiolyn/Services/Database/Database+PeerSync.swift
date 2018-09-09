//
//  Database.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/24/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let klMainStatusChanged = Notification.Name("klMainOffline")
    static let klPeerSyncProgressChanged = Notification.Name("klPeerSyncProgressChanged")
}

/// Contains all the logic relating to PeerSync, including
///
/// # Sync services (MAIN)
/// # Sync services discovering (SUB)
/// # Peer sync controlling (SUB)
extension Database {
    /// Start Peer-2-Peer syncing process.
    ///
    /// - Parameter peerUri: the target URI to sync with
    func start(peerSync url: URL) {
        guard let database = self.database else { return }
        
        peerPushReplication = database.createPullReplication(url)
        peerPushReplication?.continuous = true
        
        peerPullReplication = database.createPullReplication(url)
        peerPullReplication?.continuous = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(Database.peerReplicationChanged(_:)), name: Notification.Name.cblReplicationChange, object: peerPushReplication!)
        NotificationCenter.default.addObserver(self, selector: #selector(Database.peerReplicationChanged(_:)), name: Notification.Name.cblReplicationChange, object: peerPullReplication!)

        peerPushReplication?.start()
        i("Started peer-push-replication")
        peerPullReplication?.start()
        i("Started peer-pull-replication")
    }
    
    /// Handle changes of peer sync
    ///
    /// - Parameter notification: the notification object
    @objc func peerReplicationChanged(_ notification: Notification) {
        // Make sure the pull/pubh are not null, they are null when Peer Sync is stopped
        guard let pull = peerPullReplication, let push = peerPushReplication else { return }
        //print("****** \(pull.status.rawValue) /  \(pull.status.rawValue) ******")
        // HACK: nowhere on the Interner tell the reason why the 2 replications always start with offline statuses
        if pull.status == .offline && push.status == .offline {
            return
        }
        if let err = pull.lastError {
            w("PEER SYNC [PULL] ERROR: \(err.localizedDescription)")
        }
        if let err = push.lastError {
            w("PEER SYNC [PUSH] ERROR: \(err.localizedDescription)")
        }
        // Get the active status
        if push.status == .active || pull.status == .active {
            let total = pull.changesCount + push.changesCount
            let completed = pull.completedChangesCount + push.completedChangesCount
            if total > 0 {
                NotificationCenter.default.post(name: Notification.Name.klPeerSyncProgressChanged, object: self, userInfo: ["progress": Double(completed) / Double(total)])
            }
        }
    }
    
    /// Stop the Peer-2-Peer syncing process.
    func stopPeerSync() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.cblReplicationChange, object: peerPullReplication)
        peerPullReplication?.stop()
        peerPullReplication = nil
        i("Stopped peer-pull-replication")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.cblReplicationChange, object: peerPushReplication)
        peerPushReplication?.stop()
        peerPushReplication = nil
        i("Stopped peer-push-replication")
    }

    //    private CouchbaseLiteServiceListener cblServiceListener
    //    private CouchbaseLiteServiceBroadcaster cblServiceBroadcaster
    //    private CouchbaseLiteServiceBrowser cblServiceBrowser
    
    ///
    /// Start listener and bonjour broadcaster.
    ///
    func start(syncServices main: Bool) {
        stopSyncServices() // Stop the old ones first, then start new ones (GOOD???)
        if (main) {
        //    {
        //    ushort port = 0
        //    Socket sock = null
        //    try
        //    {
        //    sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp)
        //    sock.Bind(new IPEndPoint(IPAddress.Parse("127.0.0.1"), 0))
        //    port = (ushort)((IPEndPoint)sock.LocalEndPoint).Port
        //    }
        //    catch (Exception e)
        //    {
        //    E("Failed getting new port", e)
        //    throw e
        //    }
        //    finally
        //    {
        //    if (sock != null) try { sock.Close() } finally { }
        //    }
        //
        //    try
        //    {
        //    cblServiceListener = new CouchbaseLiteTcpListener(manager, port, configuration.MainName)
        //    //cblServiceListener.SetPasswords(new Dictionary<string, string> { { "test", "123" } })
        //    cblServiceListener.Start()
        //    I($"Started Listenter at {port}")
        //    }
        //    catch (Exception e)
        //    {
        //    E("Failed starting Listener", e)
        //    throw e
        //    }
        //
        //    try
        //    {
        //    // Start the broadcaster
        //    cblServiceBroadcaster = new CouchbaseLiteServiceBroadcaster(new RegisterService(), port)
        //    cblServiceBroadcaster.Name = configuration.MainName
        //    cblServiceBroadcaster.Start()
        //    I("Started Service Broadcaster")
        //    }
        //    catch (Exception e)
        //    {
        //    E("Failed starting Service Broadcaster -", e)
        //    throw e
        //    }
        } else {
            let runLoop = RunLoop.current
            mainServiceBrowser = NetServiceBrowser()
            mainServiceBrowser?.stop()
            mainServiceBrowser?.delegate = self
            mainServiceBrowser?.schedule(in: runLoop, forMode: .defaultRunLoopMode)
            mainServiceBrowser?.searchForServices(ofType: "_http._tcp.", inDomain: "local")
            runLoop.run()
        }
    }
    
    ///
    /// Stop listener and bonjour broadcaster.
    ///
    func stopSyncServices() {
        //    if (cblServiceBroadcaster != null)
        //    {
        //    try { cblServiceBroadcaster.Stop() }
        //    catch (Exception e) { E($"Error stopping service broadcaster", e) }
        //    finally { cblServiceBroadcaster = null }
        //    }
        //
        mainService = nil
        mainServiceBrowser?.stop()
        mainServiceBrowser = nil
        //
        //    if (cblServiceListener != null)
        //    {
        //    try { cblServiceListener.Stop() }
        //    catch (Exception e) { E($"Error stopping service listener", e) }
        //    finally { cblServiceListener = null }
        //    }
    }    
    
    /// Return true if sync services is already running.
    ///
    /// - Parameter main: `true` to check for main services, `false` for sub
    /// - Returns: `true` if the checked services are running.
    func isSyncServices(running main: Bool) -> Bool {
        if main { return true }
        else { return mainService != nil }
    }
}

// MARK: - Handle Main on/off
extension Database: NetServiceBrowserDelegate {
    /// If main service is found, normally there is no address yet, we need a further
    /// step to resolve the service address.
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        // Make sure name is matched
        guard service.name.hasPrefix(self.configuration.mainName) else { return }
        v("Resolving main service \(service.name)")
        mainService = service
        mainService?.delegate = self
        mainService?.resolve(withTimeout: 60000)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        // Make sure name is matched
        guard service.name == self.configuration.mainName else { return }
        i("Main Station offline")
        // Inform UI to update
        NotificationCenter.default.post(name: Notification.Name.klMainStatusChanged, object: self)
        // Stop the peer sync
        stopPeerSync()
    }
}

extension Database: NetServiceDelegate {
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        e("Could not resolve service \(sender.name)")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let svc = mainService, svc == sender,
            let host = svc.addresses?.first?.asNSIPAddress,
            let storeID = svc.name.components(separatedBy: ":").last,
            let mainURL = URL(string: "http://\(host):\(svc.port)/kiolyn") else {
            e("Could not resolve URL for \(sender.name)")
            return
        }
        i("Found Main Station at \(mainURL) with store \(storeID)")
        // Inform UI to update
        NotificationCenter.default.post(name: Notification.Name.klMainStatusChanged, object: self, userInfo: ["mainURL": mainURL, "storeID": storeID])
        // Sync with Main right away
        start(peerSync: mainURL)
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
