//
//  Configuration.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/24/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

/// Contains the different Environment settings for Staging and Production. Implemented following this doc https://cocoacasts.com/switching-environments-with-configurations/
enum Configuration: String {
    case staging
    case production
    
    /// Return the current configuration based on build config
    static var current: Configuration {
        #if DEBUG
            return .staging
        #else
            return .production
        #endif
    }
    
    /// Return the root URL for API.
    static var apiRootURL: String {
        switch Configuration.current {
        case .staging: return "http://kiolyn-api.willbe.vn" // "http://localhost:56103"//
        case .production: return "https://api.kiolyn.com"
        }
    }
    /// Return the root URL for sync-gateway.
    static var syncRootURL: String {
        switch Configuration.current {
        case .staging: return "http://sync-gateway.willbe.vn/kiolyn"
        case .production: return "https://sync-gateway.kiolyn.com/kiolyn"
        }
    }
    /// Return the root URL for loading images.
    static var cdnRootURL: String {
        switch Configuration.current {
        case .staging: return "http://kiolyn-cdn.willbe.vn"
        case .production: return "https://cdn.kiolyn.com"
        }
    }
    /// `True` to enable logging of peer sync document.
    static var logPeerSyncChanges: Bool {
        switch Configuration.current {
        case .staging: return true
        case .production: return false
        }
    }
    static var cashierPrinter: String { return "Cashier" }
    
    static var mainName: String { return "q8ctuHjYpheAKBA3" }
    static var mainPort: UInt { return 25610 }


    #if DEBUG
    static var logLoadedDocument: Bool { return false }
    static var verboseLogging: Bool { return true }
    static var testPrinting: Bool { return true }
    #else
    static var logLoadedDocument: Bool { return false }
    static var verboseLogging: Bool { return false }
    static var testPrinting: Bool { return false }
    #endif

    static var standalone: Bool { return false }
    static var initialMain: (URL, String)? {
//        #if DEBUG
//        return (URL(string: "http://localhost:25610")!, "17082212245480") as (URL, String)
//        #else
        return nil
//        #endif
    }
}

// MARK: - Convenient extension for image url
extension Image {
    /// Return image url based on current configuration.
    var url: URL? {
        guard file.isNotEmpty else { return nil }
        return URL(string: "\(Configuration.cdnRootURL)/\(file)")
    }
}
