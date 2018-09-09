//
//  IdleDetector.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 10/19/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Class for idle manager
class IdleManager {
    
    let disposeBag = DisposeBag()
    
    /// The timeout in seconds, after which should perform custom actions
    /// such as disconnecting the user
    var idleTimer: Timer?
    let idleSecBehaviour: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    
    private var counter = 0
    
    /// Wait for 5s before emitting
    private let waitCounter: Int = 5
    
    /// Use to check active idle time and start timer
    var isActive: Bool = false {
        didSet {
            if isActive == oldValue { return }
            if isActive {
                start()
            } else {
                stop()
            }
        }
    }
    
    private func stop() {
        idleTimer?.invalidate()
        idleTimer = nil
        idleSecBehaviour.accept(0)
    }
    
    private func start() {
        stop()
        counter = 0
        DispatchQueue.main.async {
            self.idleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(IdleManager.tick), userInfo: nil, repeats: true)
        }
    }
    
    /// If the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func tick() {
        guard isActive else { return }
        
        let idleSec = counter - waitCounter
        if idleSec > 0 {
            //print("Notify idleness of \(idleSec)")
            idleSecBehaviour.accept(idleSec)
        }
        counter += 1
    }
}
