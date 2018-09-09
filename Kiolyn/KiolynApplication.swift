//
//  KiolynApplication.swift
//  Kiolyn
//
//  Created by Tien Pham on 10/18/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import RxSwift

class KiolynApplication: UIApplication {

    override func sendEvent(_ event: UIEvent) {
        // Ignore .Motion and .RemoteControl event simply everything else then .Touches
        guard SP.idleManager.isActive, event.type == .touches else {
            super.sendEvent(event)
            return
        }
        
        /// Touches only
        let restartTimer: Bool = !(event.allTouches?.unique().any({ (touch: UITouch) -> Bool in
            return touch.phase != .cancelled && touch.phase != .ended
        }) ?? true)
        
        /// Handle stop | restart timer
        SP.idleManager.isActive = restartTimer
        super.sendEvent(event)
    }
}
