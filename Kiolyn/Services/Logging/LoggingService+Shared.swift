//
//  LoggingService+Shared.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 4/14/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - Logging
func e(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    e("\(error.localizedDescription)", functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}
func e(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    SP.logger.error(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}
func w(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    SP.logger.warn(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}
func i(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    SP.logger.info(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}
func d(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    SP.logger.debug(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}
func v(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    SP.logger.verbose(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
}
