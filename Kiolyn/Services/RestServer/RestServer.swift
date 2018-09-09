//
//  RestServer.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/7/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import Swifter
import RxSwift
import AwaitKit

class RestServer {
    /// The shared bag for disposing common subscribers.
    private let disposeBag = DisposeBag()
    /// The internal web server
    private var httpServer: HttpServer? = nil
    /// Hold the list of websocket session (Sub's connections)
    private var sessions: [WebSocketSession] = []
    
    /// Start the RestServer on given port.
    ///
    /// - Parameter port: the port to start listening on.
    /// - Throws: any error the HttpServer throws.
    func start(port: UInt) throws {
        let server = HttpServer()
        // Logging middleware
        server.middleware = [
            { request in
                d("[RestServer] \(request.method) \(request.path)")
                return nil
            }
        ]
        // Register endpoints
        register(documentApi: server)
        register(storeApi: server)
        register(eventApi: server)
        try server.start(in_port_t(port))
        // Kee for later
        httpServer = server
    }
    
    func stop() {
        httpServer?.stop()
    }
    
    /// Middleware to wrap everything inside db async.
    /// This should work because the API is totally for db querying.
    ///
    /// - Parameter handler: the real handler
    /// - Returns: the wrapped handler
    private func dbAsync(_ handler: @escaping ((HttpRequest) -> HttpResponse)) -> ((HttpRequest) -> HttpResponse) {
        return { request -> HttpResponse in
            do {
                let response = try await(
                    SP.database.async {
                        handler(request)
                    })
                switch response {
                case let .ok(body):
                    d("[RestServer] \(request.method) \(request.path) OK \(body)")
                default:
                    d("[RestServer] \(request.method) \(request.path) ERROR \(response)")
                }
                return response
            } catch {
                return .internalServerError
            }
        }
    }
    
    /// Generic method without bounding to Store.
    ///
    /// - Parameter httpServer: the http server to register with.
    private func register(documentApi httpServer: HttpServer) {
        let db = SP.database
        httpServer.GET["/doc/:documentID"] = { request -> HttpResponse in
            guard let docID = request.params[":documentID"] else {
                return .badRequest(nil)
            }
            guard let properties = try? await(db.async { db.load(properties: docID) }) else {
                return .notFound
            }
            return .ok(.json(properties as AnyObject))
        }
        
        httpServer.GET["/docs"] = { request -> HttpResponse in
            guard let idsValue = request.query(for: "ids") else {
                return .badRequest(nil)
            }
            let ids = idsValue.split(separator: ",")
                .map { id in id.trimmingCharacters(in: .whitespaces)}
            return .ok(.json(db.loadProperties(multi: ids) as AnyObject))
        }
        
        httpServer.POST["/docs"] = { request -> HttpResponse in
            guard let docs = request.arrayJson() else {
                return .badRequest(nil)
            }
            do {
                return .ok(.json(try db.save(properties: docs) as AnyObject))
            } catch {
                return .internalServerError
            }
        }
    }
    
    /// The signin request
    struct SigninRequest: Codable {
        var station_id: String
        var passkey: String
    }
    
    /// Verify the permission request
    struct VerifyPermissionRequest: Codable {
        var station_id: String
        var passkey: String
        var permission: String
    }
    
    /// The lock orders request
    struct LockOrderRequest: Codable {
        var station_id: String
        var orders: [String]
    }
    
    /// The unlock all request
    struct UnlockAllOrderRequest: Codable {
        var station_id: String
    }
    
    /// Merge order requests
    struct MergeOrdersRequest: Codable {
        var orders: [String]
    }
    
    /// Store's specific methods.
    ///
    /// - Parameter httpServer: the http server to register with.
    private func register(storeApi httpServer: HttpServer) {
        let db = SP.database
        let ds = SP.dataService
        httpServer.GET["/store/:storeID/station/:mac"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let mac = request.params[":mac"] else {
                    return .badRequest(nil)
            }
            guard let properties = db.loadStation(properties: storeID, byMacAddress: mac) else {
                return .notFound
            }
            return .ok(.json(properties as AnyObject))
        }
        
        httpServer.POST["/store/:storeID/signin"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let content: SigninRequest = request.json() else {
                    return .badRequest(nil)
            }
            guard let store: Store = db.load(storeID), let station: Station = db.load(content.station_id) else {
                return .notFound
            }
            do {
                let id = try SP.authService.verify(signin: store, station: station, withPasskey: content.passkey)
                return .ok(.json([
                    "employee": id.employee.toJSON(),
                    "settings": id.settings.toJSON(),
                    "default_printer": id.defaultPrinter?.toJSON() ?? [:],
                    "ccdevice": id.ccDevice?.toJSON()
                    ] as AnyObject))
            } catch {
                return .forbidden
            }
        }
        
        httpServer.POST["/store/:storeID/permission"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let content: VerifyPermissionRequest = request.json() else {
                    return .badRequest(nil)
            }
            guard let store: Store = db.load(storeID),
                let _: Station = db.load(content.station_id) else {
                    return .notFound
            }
            guard let employee = SP.authService.verify(passkey: content.passkey, havingPermission: content.permission, inStore: store) else {
                return .forbidden
            }
            return .ok(.json(employee.toJSON() as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/shift/active"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty else {
                return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(activeShift: storeID) as AnyObject))
        }
        
        httpServer.POST["/store/:storeID/shift/active/counter/:counter"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let counter = ShiftCounter(rawValue: request.params[":counter"] ?? "") else {
                    return .badRequest(nil)
            }
            do {
                let shift: [String: Any] = try ds.increase(store: storeID, counter: counter)?.toJSON() ?? [:]
                return .ok(.json(shift as AnyObject))
            } catch {
                return .internalServerError
            }
        }
        
        httpServer.GET["/store/:storeID/all/:type"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let type = request.params[":type"],
                let modelType = NSClassFromString("Kiolyn.\(type)") as? BaseModel.Type else {
                    return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(all: storeID, for: modelType, byName: "") as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/order/opening"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let areaID = request.query(for: "areaid"),
                let filter = request.query(for: "filter"),
                let shiftID = request.query(for: "shiftid") else {
                    return .badRequest(nil)
            }
            guard let area: Area = db.load(areaID) else {
                return .notFound
            }
            return .ok(.json(db.loadProperties(openingOrders: storeID, forShift: shiftID, inArea: area, withFilter: filter) as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/order/locked"] = dbAsync { request -> HttpResponse in
            return .ok(.json(ds.lockedOrders.value as AnyObject))
        }
        
        httpServer.POST["/store/:storeID/order/lock"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let content: LockOrderRequest = request.json()  else {
                    return .badRequest(nil)
            }            
            do {
                let orders = try ds.lock(orders: content.orders, forStation: content.station_id)
                return .ok(.json(orders as AnyObject))
            } catch {
                return .internalServerError
            }
        }
        
        httpServer.POST["/store/:storeID/order/unlock-all"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let content: UnlockAllOrderRequest = request.json()  else {
                    return .badRequest(nil)
            }
            ds.unlock(allOrders: content.station_id)
            return .ok(.json(true as AnyObject))
        }
        
        httpServer.DELETE["/store/:storeID/order/:orderID"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let orderID = request.params[":orderID"] else {
                    return .badRequest(nil)
            }
            do {
                try db.delete("\(Order.documentIDPrefix)_\(orderID)")
                ds.remoteOrderChanged.on(.next([orderID]))
                return .ok(.json([String: Any]() as AnyObject))
            } catch {
                return .internalServerError
            }
        }
        
        httpServer.POST["/store/:storeID/order"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let properties = request.json(),
                let orderID = properties["id"] as? String, orderID.isNotEmpty else {
                    return .badRequest(nil)
            }
            do {
                let rev = try db.save(properties: properties)
                ds.remoteOrderChanged.on(.next([orderID]))
                return .ok(.json([ "result": rev] as AnyObject))
            } catch {
                return .internalServerError
            }
        }
        
        httpServer.GET["/store/:storeID/order"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let shiftID = request.query(for: "shiftid"), shiftID.isNotEmpty,
                let page = UInt(request.query(for: "page") ?? "1"),
                let pageCount = UInt(request.query(for: "pageCount") ?? "10") else {
                    return .badRequest(nil)
            }
            let status = OrderStatus(rawValue: request.query(for: "status") ?? "") ?? .new
            let queryResult = db.loadProperties(orders: storeID, forShift: shiftID, matchingStatuses: [status], page: page, pageSize: pageCount)
            return .ok(.json(queryResult as AnyObject))
        }
        
        httpServer.POST["/store/:storeID/order/merge"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let content: MergeOrdersRequest = request.json()  else {
                    return .badRequest(nil)
            }
            let loadedOrders: [Order?] = db.load(multi: content.orders)
            let orders: [Order] = loadedOrders
                .filter { order in order != nil }
                .map { order -> Order in order! }
            guard let mergedOrder = orders.first else {
                return .badRequest(nil)
            }
            let fromOrders = Array(orders[1..<orders.count])
            _ = mergedOrder.merge(orders: fromOrders)
            do {
                var rev: String!
                try db.runBatch {
                    rev = try db.save(properties: mergedOrder.toJSON())
                    try db.delete(multi: fromOrders)
                }
                ds.remoteOrderChanged.on(.next(content.orders))
                return .ok(.json(["result": rev] as AnyObject))
            } catch {
                return .internalServerError
            }
        }
        
        httpServer.GET["/store/:storeID/category/:categoryID/items"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let categoryID = request.params[":categoryID"] else {
                    return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(items: storeID, forCategory: categoryID) as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/item/barcode/:barcode"] = dbAsync { request -> HttpResponse in
            return .notFound
        }
        
        httpServer.GET["/store/:storeID/item/:itemID/modifiers"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let itemID = request.params[":itemID"] else {
                    return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(modifiers: itemID) as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/modifier/global"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty else {
                return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(globalModifiers: storeID) as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/customer"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let page = UInt(request.query(for: "page") ?? "1"),
                let pageCount = UInt(request.query(for: "pageCount") ?? "10") else {
                    return .badRequest(nil)
            }
            return .ok(.json(db.load(customers: storeID, page: page, pageSize: pageCount).toJSON() as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/customer/find"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty,
                let name = request.query(for: "customername"),
                let phone = request.query(for: "customerphone"),
                let email = request.query(for: "customeremail"),
                let address = request.query(for: "customeraddress"),
                let limit = UInt(request.query(for: "pageCount") ?? "10")else {
                    return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(customers: storeID, query: (name, phone, email, address), limit: limit) as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/driver/default"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty else {
                return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(defaultDriver: storeID) as AnyObject))
        }
        
        httpServer.GET["/store/:storeID/driver"] = dbAsync { request -> HttpResponse in
            guard let storeID = request.params[":storeID"], storeID.isNotEmpty else {
                return .badRequest(nil)
            }
            return .ok(.json(db.loadProperties(drivers: storeID) as AnyObject))
        }
    }
    
    /// Send a message to ALL listeners.
    ///
    /// - Parameters:
    ///   - type: the message type.
    ///   - content: the message content.
    func send(message type: ServerEventType, content: Any?) {
        do
        {
            var message = ""
            if let content = content {
                let data = try JSONSerialization.data(withJSONObject:[
                    "type": type.rawValue,
                    "content": content])
                message = String(data: data, encoding: .utf8) ?? ""
            }
            for client in sessions {
                client.writeText(message)
            }
        } catch {
            e("[RestServer] Failed sending message \(error)")
        }
    }
    
    /// Event specific endpoints.
    ///
    /// - Parameter httpServer: the http server to register with.
    private func register(eventApi httpServer: HttpServer) {
        SP.dataService.lockedOrders
            .subscribe(onNext: { lockedOrders in
                self.send(message: .lockedOrdersChanged, content: lockedOrders)
            })
            .disposed(by: disposeBag)
        SP.dataService.activeShift
            .subscribe(onNext: { shift in
                self.send(message: .activeShiftChanged, content: nil)
            })
            .disposed(by: disposeBag)
        SP.dataService.localOrderChanged
            .subscribe(onNext: { orderIDs in
                guard orderIDs.isNotEmpty else { return }
                self.send(message: .orderChanged, content: orderIDs.joined(separator: ","))
            })
            .disposed(by: disposeBag)
        
        httpServer.GET["/event"] = { r -> HttpResponse in
            guard r.hasTokenForHeader("upgrade", token: "websocket") else {
                return .badRequest(.text("Invalid value of 'Upgrade' header: \(r.headers["upgrade"] ?? "unknown")"))
            }
            guard r.hasTokenForHeader("connection", token: "upgrade") else {
                return .badRequest(.text("Invalid value of 'Connection' header: \(r.headers["connection"] ?? "unknown")"))
            }
            guard let secWebSocketKey = r.headers["sec-websocket-key"] else {
                return .badRequest(.text("Invalid value of 'Sec-Websocket-Key' header: \(r.headers["sec-websocket-key"] ?? "unknown")"))
            }
            
            let protocolSessionClosure: ((Socket) -> Void) = { socket in
                let session = WebSocketSession(socket)
                var fragmentedOpCode = WebSocketSession.OpCode.close
                var payload = [UInt8]() // Used for fragmented frames.
                
                func handle(operationCode frame: WebSocketSession.Frame) throws {
                    switch frame.opcode {
                    case .continue:
                        // There is no message to continue, failed immediatelly.
                        if fragmentedOpCode == .close {
                            socket.close()
                        }
                        frame.opcode = fragmentedOpCode
                        if frame.fin {
                            payload.append(contentsOf: frame.payload)
                            frame.payload = payload
                            // Clean the buffer.
                            payload = []
                            // Reset the OpCode.
                            fragmentedOpCode = WebSocketSession.OpCode.close
                        }
                        try handle(operationCode: frame)
                    case .close:
                        throw WebSocketSession.Control.close
                    case .ping:
                        if frame.payload.count > 125 {
                            throw WebSocketSession.WsError.protocolError("Payload gretter than 125 octets.")
                        } else {
                            session.writeFrame(ArraySlice(frame.payload), .pong)
                        }
                    default: break
                    }
                }
                
                // Append the session to the list of session
                self.sessions.append(session)
                defer {
                    // When ever come to an end, remove the session from the list of sessions
                    if let index = self.sessions.index(of: session) {
                        self.sessions.remove(at: index)
                    }
                }
                
                do {
                    while true {
                        let frame = try session.readFrame()
                        try handle(operationCode: frame)
                    }
                } catch let error {
                    switch error {
                    case WebSocketSession.Control.close:
                        // Normal close
                        break
                    case WebSocketSession.WsError.unknownOpCode:
                        e("[RestServer] Unknown Op Code: \(error)")
                    case WebSocketSession.WsError.unMaskedFrame:
                        e("[RestServer] Unmasked frame: \(error)")
                    case WebSocketSession.WsError.invalidUTF8:
                        e("[RestServer] Invalid UTF8 character: \(error)")
                    case WebSocketSession.WsError.protocolError:
                        e("[RestServer] Protocol error: \(error)")
                    default:
                        e("[RestServer] Unkown error \(error)")
                    }
                    // If an error occurs, send the close handshake.
                    session.writeCloseFrame()
                }
            }
            guard let secWebSocketAccept = String.toBase64((secWebSocketKey + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").sha1()) else {
                return .internalServerError
            }
            let headers = ["Upgrade": "WebSocket", "Connection": "Upgrade", "Sec-WebSocket-Accept": secWebSocketAccept]
            return HttpResponse.switchProtocols(headers, protocolSessionClosure)
        }
    }
}

fileprivate extension HttpRequest {
    func query(for key: String) -> String? {
        return queryParams.first { k, _ in key == k }?.1
    }
    
    func json() -> [String: Any]? {
        do {
            let data = Data(bytes: body)
            //            v("[RestServer] Content: \(String(data: data, encoding: .utf8))")
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            w("[RestServer] Invalid input \(error)")
            return nil
        }
    }
    
    func arrayJson() -> [[String: Any]]? {
        do {
            let data = Data(bytes: body)
            //            v("[RestServer] Content: \(String(data: data, encoding: .utf8))")
            return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        } catch {
            w("[RestServer] Invalid input \(error)")
            return nil
        }
    }
    
    func json<T:Codable>() -> T? {
        do {
            let data = Data(bytes: body)
            //            v("[RestServer] Content: \(String(data: data, encoding: .utf8))")
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            w("[RestServer] Invalid input \(error)")
            return nil
        }
    }
}
