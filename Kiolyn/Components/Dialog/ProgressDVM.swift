//
//  ProgressDVM.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/29/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

class ProgressDVM: DialogViewModel<Void> {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}
