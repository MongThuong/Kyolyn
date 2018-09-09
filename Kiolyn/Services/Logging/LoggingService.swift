//
//  LoggingService.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 3/5/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation

/// Provide all the necessary logging methods.
class LoggingService {

    /// Log something at the Error log level.
    ///
    /// - Parameters:
    ///   - closure: A closure that returns the object to be logged.
    ///   - functionName: Normally omitted **Default:** *#function*.
    ///   - fileName: Normally omitted **Default:** *#file*.
    ///   - lineNumber: Normally omitted **Default:** *#line*.
    ///   - userInfo: Dictionary for adding arbitrary data to the log message, can be used by filters/formatters etc.
    func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        print("[ERROR] \(functionName) \(fileName):\(lineNumber) \(closure() ?? "")")
    }
    
    /// Log something at the Warn log level.
    ///
    /// - Parameters:
    ///   - closure: A closure that returns the object to be logged.
    ///   - functionName: Normally omitted **Default:** *#function*.
    ///   - fileName: Normally omitted **Default:** *#file*.
    ///   - lineNumber: Normally omitted **Default:** *#line*.
    ///   - userInfo: Dictionary for adding arbitrary data to the log message, can be used by filters/formatters etc.
    func warn(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        print("[WARN] \(functionName) \(fileName):\(lineNumber) \(closure() ?? "")")
    }
    
    /// Log something at the Info log level.
    ///
    /// - Parameters:
    ///   - closure: A closure that returns the object to be logged.
    ///   - functionName: Normally omitted **Default:** *#function*.
    ///   - fileName: Normally omitted **Default:** *#file*.
    ///   - lineNumber: Normally omitted **Default:** *#line*.
    ///   - userInfo: Dictionary for adding arbitrary data to the log message, can be used by filters/formatters etc.
    func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        print("[INFO] \(functionName) \(fileName):\(lineNumber) \(closure() ?? "")")
    }
    
    
    /// Log something at the Debug log level.
    ///
    /// - Parameters:
    ///   - closure: A closure that returns the object to be logged.
    ///   - functionName: Normally omitted **Default:** *#function*.
    ///   - fileName: Normally omitted **Default:** *#file*.
    ///   - lineNumber: Normally omitted **Default:** *#line*.
    ///   - userInfo: Dictionary for adding arbitrary data to the log message, can be used by filters/formatters etc.
    func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        print("[DEBUG] \(functionName) \(fileName):\(lineNumber) \(closure() ?? "")")
    }
    
    /// Log something at the Verbose log level.
    ///
    /// - Parameters:
    ///   - closure: A closure that returns the object to be logged.
    ///   - functionName: Normally omitted **Default:** *#function*.
    ///   - fileName: Normally omitted **Default:** *#file*.
    ///   - lineNumber: Normally omitted **Default:** *#line*.
    ///   - userInfo: Dictionary for adding arbitrary data to the log message, can be used by filters/formatters etc.
    func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [String: Any]()) {
        print("[VERBOSE] \(functionName) \(fileName):\(lineNumber) \(closure() ?? "")")
    }
    
    
    /// Check if logging level is debug.
    ///
    /// - Returns: `true` if the current level is higher than debug.
    func shouldLogDebug() -> Bool {
        return true
    }
}

