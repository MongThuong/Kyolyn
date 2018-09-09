//
//  Printer.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Type of `Printer`.
enum PrinterType: String {
    case usb = "USB"
    case ethernet = "Ethernet"
    case bluetooth = "Bluetooth"
    case noprinter = "No Printer"
}

/// Family of `Printer`
///
/// - thermal: thermal (Star, Epson)
/// - label: label (Brother)
enum PrinterModel {
    case star(model: String)
    case brother(model: String)
    
    /// True if this model is a label printer
    var isLabelPrinter: Bool {
        switch self {
        case .star: return false
        case .brother: return true
        }
    }
    
    /// The real life model name
    var name: String {
        switch self {
        case let .star(model): return "Star \(model)"
        case let .brother(model): return "Brother \(model)"
        }
    }
}

class PrinterModelTransform: TransformType {
    public typealias Object = PrinterModel
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> PrinterModel? {
        if let raw = value as? String {
            if raw.starts(with: "Star") {
                return .star(model: raw.right(from: 5))
            } else if raw.starts(with: "Brother") {
                return .brother(model: raw.right(from: 8))
            }
        }
        return .star(model: "TSP100")
    }
    
    open func transformToJSON(_ value: PrinterModel?) -> String? {
        return value?.name
    }
}


/// Represent a `Printer` in system, this `Printer` is not meant to be updated but getting from a Sync Session API call.
class Printer: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "printer" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "prt" }
    /// Return ALL `Printer` that
    /// 1. Has id
    /// 2. Has merchant id
    /// 3. Not yet deleted
    /// 4. Not disabled
    /// 5. Has a name
    override class var allMapBlock: CBLMapBlock? {
        return { (doc, emit) in
            // Make sure good inputs
            guard doc["deleted"] == nil,
                let type = doc["type"] as? String, type == documentType,
                let id = doc["id"] as? String, id.isNotEmpty,
                let merchantID = doc["merchantid"] as? String, merchantID.isNotEmpty,
                // not disabled
                (doc["enabled"] as? Bool ?? false) == true,
                // having a good name
                let name = doc["name"] as? String, name.isNotEmpty else {
                    return
            }
            // User storeid (new Store) or merchantid (old Store)
            let storeID = (doc["storeid"] as? String) ?? merchantID
            emit(storeID, nil)
        }
    }

    // Location
    var location = ""
    /// Type of device, possible values are
    var printerType: PrinterType = .ethernet
    /// Available for Ethernet type only, the mac address of this Device.
    var macAddress = ""
    /// Available for Ethernet type only, the IP address of this Device, detected and set on the fly.
    var ipAddress = ""
    /// The model of the printer
    var printerModel = PrinterModel.star(model: "TSP100")

    override func mapping(map: Map) {
        super.mapping(map: map)
        ipAddress <- map["ip_address"]
        location <- map["location"]
        printerType <- (map["printer_type"], EnumTransform<PrinterType>())
        macAddress <- map["mac_address"]
        ipAddress <- map["ip_address"]
        printerModel <- (map["printer_model"], PrinterModelTransform())
    }
}

extension Printer {
    /// Create a placeholder printer where logic require a Printer but we cannot identify a Printer to user.
    ///
    /// - Parameter database: The database to create in.
    /// - Returns: The placeholder `Printer`
    /// - Throws: Model error.
    static var noPrinter: Printer {
        let printer = Printer(id: "no")
        printer.name = "No Printer"
        return printer
    }
}

extension Printer {
    var hasIPAddress: Bool { return self.ipAddress.isNotEmpty }
    var noIPAddress: Bool { return !hasIPAddress }
    
    /// True is the printer is valid and can be used. All printer type except Ethernet are valid by default, but for Ethernet we require the MAC address to exist in order to be considered as valid.
    var isValid: Bool { return printerType != .ethernet || !macAddress.isEmpty }
    
    override var debugDescription: String {
        let detail = printerType == .ethernet ? "\(ipAddress.isEmpty ? "INVALID" : ipAddress)" : printerType.rawValue
        return "\(name) (\(detail))"
    }
}
