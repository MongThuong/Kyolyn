//
//  CCDevice.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/6/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import ObjectMapper

/// Type of `CCDevice`.
enum CCDeviceType: String {
    case usb = "USB"
    case ethernet = "Ethernet"
    case bluetooth = "Bluetooth"
    case standalone = "Standalone Terminal"
    case nodevice = "No Device"
}

/// Represent a `CCDevice` in system, this `CCDevice` is not meant to be updated but getting from a database sync.
class CCDevice: BaseModel {
    /// Document type of this class
    override class var documentType: String { return "ccdevice" }
    /// The prefix to be used for calculating the document id.
    override class var documentIDPrefix: String { return "ccd" }
    
    /// Type of device, possible values are
    var ccDeviceType: CCDeviceType = .ethernet
    /// Where is this Device located.
    var location = ""
    /// Status of this device.
    var enabled = false
    /// Status of this device.
    var secure = false
    /// Available for Ethernet type only, the mac address of this Device.
    var macAddress = ""
    /// Available for Ethernet type only, the IP address of this Device, detected and set on the fly.
    var ipAddress = ""
    /// The working port of this Device. Default to PAX's 10009.
    var port: String { return "10009" }
    /// Return the scheme to be used with this device
    var scheme: String { return secure ? "https" : "http" }
    /// Return the root URL to this Device
    var hostUrl: String { return "\(scheme)://\(ipAddress):\(port)" }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        ccDeviceType <- (map["ccdevice_type"], EnumTransform<CCDeviceType>())
        location <- map["location"]
        enabled <- map["enabled"]
        secure <- map["secure"]
        macAddress <- map["mac_address"]
        ipAddress <- map["ip_address"]
    }
}

extension CCDevice {
    /// `true` if the device is standalone one
    var isStandalone: Bool { return ccDeviceType == .standalone }
    var isNotStandalone: Bool { return !isStandalone }
    /// `true` if the device is nodevice one
    var isNoDevice: Bool { return ccDeviceType == .nodevice }
}
