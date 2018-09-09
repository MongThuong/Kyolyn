//
//  CCResult.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

protocol CCResult {
    var displayCode: String { get }
    var displayMessage: String { get }
    var isApproved: Bool { get }
    var resultCode: String { get }
    var resultTxt: String { get }
    var message: String? { get }
    var extData: String? { get }
    var hostCode: String? { get }
    var authCode: String? { get }
}
