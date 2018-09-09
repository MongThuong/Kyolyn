//
//  MessageDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 8/30/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

enum MessageDR {
    case no
    case yes
    case neutral
}

enum MessageDT {
    case info
    case error
    case confirm
}

class MessageDVM: DialogViewModel<MessageDR> {
    let message: String
    let type: MessageDT
    let yesText: String
    let noText: String
    let neutralText: String
    
    override var dialogResult: MessageDR? {
        return .no
    }
    
    init(_ message: String, type: MessageDT = .info, yesText: String = "YES", noText: String = "NO", neutralText: String = "") {
        self.message = message
        self.type = type
        self.yesText = yesText
        self.noText = noText
        self.neutralText = neutralText
    }
}
