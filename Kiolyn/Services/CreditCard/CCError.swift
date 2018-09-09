//
//  CCError.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

/// Error relating to credit card service.
enum CCError: LocalizedError {
    case deviceNotFound
    case unknown
    case invalidDevice(detail: String)
    case invalidRequest(detail: String)
    case invalidReponse(detail: String)
    case transactionError(detail: String)
    
    var errorDescription: String? {
        switch self {
        case .deviceNotFound:
            return "Device could not be found, please make sure the device is up and running."
        case .unknown:
            return "Unknown error happened during payment."
        case .invalidDevice(let detail):
            return detail
        case .invalidRequest(let detail):
            return detail
        case .invalidReponse(let detail):
            return detail
        case .transactionError(let detail):
            return detail
        }
    }
}
