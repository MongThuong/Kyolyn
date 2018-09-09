//
//  main.swift
//  Kiolyn
//
//  Created by Tien Pham on 10/18/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(KiolynApplication.self),
    NSStringFromClass(AppDelegate.self)
)
