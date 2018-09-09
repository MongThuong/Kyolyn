//
//  RestClient+ServerEvent.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/21/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import SwiftWebSocket
import ObjectMapper

extension RestClient {
    
    /// Use for restarting in case of a desync happens
    func restartEventClientIfStopped() {
        // It is there already
        if let _ = eventWS {
            return
        }
        start(eventClient: SP.stationManager.mainStation.value?.0)
    }
    
    /// Start websocket connection to main.
    func start(eventClient mainURL: URL?) {
        guard let host = mainURL?.host, let port = mainURL?.port else {
            stop(eventClient: "Main is offline")
            return
        }
        
        let eventUrl = "ws://\(host):\(port)/event"
        // Make sure we dont start 2 times
        guard eventWS?.url != eventUrl else {
            return
        }
        
        let ws = WebSocket(eventUrl)
        ws.event.open = {
            d("[WS] Opened Event stream to Main")
        }
        ws.event.close = { code, reason, clean in
            d("[WS] Closed Event stream to Main")
        }
        ws.event.error = { error in
            e("[WS] \(error.localizedDescription)")
        }
        ws.event.message = { message in
            v("[WS] Received \(message)")
            guard let json = message as? String, let em = ServerEvent(JSONString: json) else {
                return
            }
            self.raise(serverEvent: em)
        }
        // Keep it for later closing
        eventWS = ws
    }
    
    /// Handle server event.
    ///
    /// - Parameter event: the server event to raise.
    private func raise(serverEvent event: ServerEvent) {
        let ds = SP.dataService
        let auth = SP.authService
        guard let type = event.type, !auth.isSignedOut else {
            return
        }
        switch type {
        case .lockedOrdersChanged:
            guard let lockedOrders = event.content as? [String: String] else {
                return
            }
            // Locked orders changed remotely, we need to update the locked orders
            ds.lockedOrders.accept(lockedOrders)
            v("[WS] lockedOrdersChanged \(lockedOrders)")
        case .orderChanged:
            guard let orderIDs = event.content as? String else {
                return
            }
            let ids = orderIDs.components(separatedBy: ",")
            // Order changed remotely, we need to inform listener to update UI accordingly
            ds.remoteOrderChanged.onNext(ids)
            v("[WS] ordersChanged \(ids)")
        case .activeShiftChanged:
            // Shift changed remotely, we need to reload it
            _ = ds.loadActiveShift().subscribe()
            v("[WS] activeShiftChanged")
        }
    }
    
    /// Stop websocket connection to main.
    private func stop(eventClient reason: String) {
        eventWS?.close(reason: reason)
        eventWS = nil
    }
}

enum ServerEventType: String {
    case lockedOrdersChanged = "LockedOrdersChanged"
    case orderChanged = "OrderChanged"
    case activeShiftChanged = "ActiveShiftChanged"
}

fileprivate class ServerEvent: Mappable {
    var type: ServerEventType?
    var content: Any?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        type <- (map["type"], EnumTransform<ServerEventType>())
        content <- map["content"]
    }
}
