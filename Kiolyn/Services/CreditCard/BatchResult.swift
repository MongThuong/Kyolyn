//
//  BatchResult.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

protocol BatchResult: CCResult {
    var batchNum: String? { get }
    var hostTraceNum: String? { get }
    var mid: String? { get }
    var tid: String? { get }
    var timestamp: String? { get }
    var totalAmount: Double { get }
    var totalCount: Int { get }
    var hostResponse: String? { get }
}
