//
//  XCGLoggingService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/14/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import XCGLogger

/// [XCGLogger](https://github.com/DaveWoodCom/XCGLogger) implementation of the LoggingService.
class XCGLoggingService: LoggingService {
    
    /// Return the `XCGLogger` instance.
    private lazy var logger: XCGLogger = {
        // Create a logger object with no destinations
        let logger = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
        
        // Create a destination for the system console log (via NSLog)
        let systemDestination = AppleSystemLogDestination(identifier: "kiolyn.systemDestination")
        systemDestination.outputLevel = .debug
        systemDestination.showLogIdentifier = false
        systemDestination.showFunctionName = true
        systemDestination.showThreadName = true
        systemDestination.showLevel = true
        systemDestination.showFileName = true
        systemDestination.showLineNumber = true
        systemDestination.showDate = true
        systemDestination.logQueue = XCGLogger.logQueue
        logger.add(destination: systemDestination)
        
        // Create a file log destination
        let logPath = NSTemporaryDirectory().appending("kiolyn.log")
        let fileDestination = FileDestination(writeToFile: logPath, identifier: "kiolyn.fileDestination", shouldAppend: true)
        fileDestination.outputLevel = .debug
        fileDestination.showLogIdentifier = false
        fileDestination.showFunctionName = true
        fileDestination.showThreadName = true
        fileDestination.showLevel = true
        fileDestination.showFileName = true
        fileDestination.showLineNumber = true
        fileDestination.showDate = true
        fileDestination.logQueue = XCGLogger.logQueue
        logger.add(destination: fileDestination)

        logger.outputLevel = Configuration.verboseLogging ? .verbose : .info

        logger.logAppDetails()
        
        return logger
    }()
    
    /// Override to log with `XCGLogger`.
    override func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        logger.error(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    /// Override to log with `XCGLogger`.
    override func warn(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        logger.warning(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    /// Override to log with `XCGLogger`.
    override func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        logger.info(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    /// Override to log with `XCGLogger`.
    override func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        logger.debug(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    /// Override to log with `XCGLogger`.
    override func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        logger.verbose(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    override func shouldLogDebug() -> Bool {
        return logger.outputLevel >= .debug
    }
}
