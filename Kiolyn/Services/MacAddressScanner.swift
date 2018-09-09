//
//  NetworkUtil.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/13/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import MMLanScan

/// Error returning during scanning for devices.
enum MacAddressScanError: LocalizedError {
    case networkError
    case notFound
    case alreadyRunning
    
    var errorDescription: String? {
        switch self {
        case .networkError: return "There were error scanning"
        case .notFound: return "MAC address could not be found in LAN"
        case .alreadyRunning: return "Scanning is already started"
        }
    }
}

/// The completed block.
typealias MacAddressScanCompleted = (String?, Error?) -> Void

/// Scan for CCDevice using its Mac address
class MacAddressScanner: NSObject, MMLANScannerDelegate {
    /// Target device was found
    private var found = false
    /// The device to look for
    private var macAddress: String = ""
    /// The scanner
    private lazy var scanner = MMLANScanner(delegate: self)
    /// The callback
    private var callback: MacAddressScanCompleted?
    
    /// Start this scanner with a completion handler.
    ///
    /// - Parameter onCompleteHandler: find completed callback.
    /// - Returns: self for chaining  purpose
    func scan(for mac: String, _ scanCompleted: @escaping MacAddressScanCompleted) {
        guard let scanner = scanner else {
            e("Scanner was not initialized")
            return
        }
        guard !scanner.isScanning else {
            scanCompleted(nil, MacAddressScanError.notFound)
            return
        }
        macAddress = mac
        // Hook up callback
        callback = scanCompleted
        // Log verbose
        v("Start scanning for \(macAddress)")
        // Start scanner
        scanner.start()
    }
    
    func stop() {
        macAddress = ""
        callback = nil
        scanner?.stop()
    }
    
    // MARK: MMLANScannerDelegate
    
    func lanScanDidFailedToScan() {
        // Log verbose
        v("Scanning failed: might be a network issue")
        // From source code this is called on empty returning IP address
        callback?(nil, MacAddressScanError.networkError)
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        if !found {
            v("Scanning failed: device not found")
            callback?(nil, MacAddressScanError.notFound)
        }
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        
    }
    
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        // Make sure mac/ip are available
        guard let macAddress = device.macAddress, let ip = device.ipAddress, !ip.isEmpty else {
            return
        }
        v("Found device at \(ip)/\(macAddress)")
        let components = macAddress.components(separatedBy: ":")
        let mac = components.joined(separator: "")
        v("Matched? \(mac.lowercased() == self.macAddress.lowercased())")
        // Make sure matching of mac addresses
        guard mac.lowercased() == self.macAddress.lowercased() else {
            return
        }
        v("Found matching device at IP \(ip)")
        found = true
        // Return the ip of the mac address
        callback?(device.ipAddress, nil)
        // Stop on first match (should be last match also)
        stop()
    }
}
