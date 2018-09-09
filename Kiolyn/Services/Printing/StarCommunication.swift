//
//  Communication.swift
//  Swift SDK
//
//  Created by Yuji on 2015/**/**.
//  Copyright © 2015年 Star Micronics. All rights reserved.
//

import Foundation

let sm_true:  UInt32 = 1     // SM_TRUE
let sm_false: UInt32 = 0     // SM_FALSE

/// Handler for send command complete to printting
///
/// - result : send command success or not
/// - title  : title command
/// - message : message command
typealias SendCompletionHandler = (_ result: Bool, _ title: String, _ message: String) -> Void

/// Handler for request status printting completion
///
/// - result : request success or not
/// - title  : title request
/// - message : message request
/// - connect : the status of connection
typealias RequestStatusCompletionHandler = (_ result: Bool, _ title: String, _ message: String, _ connect: Bool) -> Void

/// Class to communication to printting
class StarCommunication {
    
    /// Send commands to printting
    /// 
    /// - commands 'command data of text string or image'
    /// - port 'port to connect with printting'
    /// - completionHandler 'callback event'
    static func sendCommands(commands: NSData!, port: SMPort!, completionHandler: SendCompletionHandler?) -> Bool {
        // Result for send success or not
        var result: Bool = false
        
        
        var title:   String = ""
        var message: String = ""
        
        var error: NSError?
        
        let length: UInt32 = UInt32(commands.length)
        
        var array: [UInt8] = [UInt8](repeating: 0, count: commands.length)
        
        commands.getBytes(&array, length: commands.length)
        
        // Send commands processing
        while true {
            // Check port
            if port == nil {
                title   = "Fail to Open Port"
                message = ""
                break
            }
            
            var printerStatus: StarPrinterStatus_2 = StarPrinterStatus_2()
            
            port.beginCheckedBlock(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
            // Check printer status
            if printerStatus.offline == sm_true {
                title   = "Printer Error"
                message = "Printer is offline (BeginCheckedBlock)"
                break
            }
            
            let startDate: NSDate = NSDate()
            
            var total: UInt32 = 0
            
            while total < length {
                let written: UInt32 = port.write(array, total, length - total, &error)
                
                if error != nil {
                    break
                }
                
                total += written
                
                if NSDate().timeIntervalSince(startDate as Date) >= 30.0 {     // 30000mS!!!
                    title   = "Printer Error"
                    message = "Write port timed out"
                    break
                }
            }
            
            if total < length {
                break
            }
            
            port.endCheckedBlockTimeoutMillis = 30000     // 30000mS!!!
            
            port.endCheckedBlock(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
            if printerStatus.offline == sm_true {
                title   = "Printer Error"
                message = "Printer is offline (EndCheckedBlock)"
                break
            }
            
            title   = "Send Commands"
            message = "Success"
            
            result = true
            break
        }
        
        if error != nil {
            title   = "Printer Error"
            message = error!.description
        }
        
        if completionHandler != nil {
            completionHandler!(result, title, message)
        }
        
        return result
    }
    
    /// Send commands to printting - dont check printer status
    ///
    /// - commands 'command data of text string or image'
    /// - port 'port to connect with printting'
    /// - completionHandler 'callback event'
    static func sendCommandsDoNotCheckCondition(commands: NSData!, port: SMPort!, completionHandler: SendCompletionHandler?) -> Bool {
        var result: Bool = false
        
        var title:   String = ""
        var message: String = ""
        
        var error: NSError?
        
        let length: UInt32 = UInt32(commands.length)
        
        var array: [UInt8] = [UInt8](repeating: 0, count: commands.length)
        
        commands.getBytes(&array, length: commands.length)
        
        // Send commands processing
        while true {
            if port == nil {
                title   = "Fail to Open Port"
                message = ""
                break
            }
            
            var printerStatus: StarPrinterStatus_2 = StarPrinterStatus_2()
            
            port.getParsedStatus(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
//          if printerStatus.offline == sm_true {     // Do not check condition.
//              title   = "Printer Error"
//              message = "Printer is offline (GetParsedStatus)"
//              break
//          }
            
            let startDate: NSDate = NSDate()
            
            var total: UInt32 = 0
            
            while total < length {
                let written: UInt32 = port.write(array, total, length - total, &error)
                
                if error != nil {
                    break
                }
                
                total += written
                
                if NSDate().timeIntervalSince(startDate as Date) >= 30.0 {     // 30000mS!!!
                    title   = "Printer Error"
                    message = "Write port timed out"
                    break
                }
            }
            
            if total < length {
                break
            }
            
            port.getParsedStatus(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
//          if printerStatus.offline == sm_true {     // Do not check condition.
//              title   = "Printer Error"
//              message = "Printer is offline (GetParsedStatus)"
//              break
//          }
            
            title   = "Send Commands"
            message = "Success"
            
            result = true
            break
        }
        
        if error != nil {
            title   = "Printer Error"
            message = error!.description
        }
        
        if completionHandler != nil {
            completionHandler!(result, title, message)
        }
        
        return result
    }
    
    /// Send commands to printer - with configuration
    ///
    /// - commands 'command data of text string or image'
    /// - portName 'port name to connect with printting'
    /// - portSettings 'port setiings to connect with printting'
    /// - timeout 'the timeout to process command'
    /// - completionHandler 'callback event'
    static func sendCommands(commands: NSData!, portName: String!, portSettings: String!, timeout: UInt32, completionHandler: SendCompletionHandler?) -> Bool {
        var result: Bool = false
        
        var title:   String = ""
        var message: String = ""
        
        var error: NSError?
        
        let length: UInt32 = UInt32(commands.length)
        
        var array: [UInt8] = [UInt8](repeating: 0, count: commands.length)
        
        commands.getBytes(&array, length: commands.length)
        
        // Send commands processing
        while true {
            guard let port: SMPort = SMPort.getPort(portName, portSettings, timeout) else {
                title   = "Fail to Open Port"
                message = ""
                break
            }
            
            defer {
                SMPort.release(port)
            }
            
            var printerStatus: StarPrinterStatus_2 = StarPrinterStatus_2()
            
            port.beginCheckedBlock(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
            if printerStatus.offline == sm_true {
                title   = "Printer Error"
                message = "Printer is offline (BeginCheckedBlock)"
                break
            }
            
            let startDate: NSDate = NSDate()
            
            var total: UInt32 = 0
            
            while total < length {
                let written: UInt32 = port.write(array, total, length - total, &error)
                
                if error != nil {
                    break
                }
                
                total += written
                
                if NSDate().timeIntervalSince(startDate as Date) >= 30.0 {     // 30000mS!!!
                    title   = "Printer Error"
                    message = "Write port timed out"
                    break
                }
            }
            
            if total < length {
                break
            }
            
            port.endCheckedBlockTimeoutMillis = 30000     // 30000mS!!!
            
            port.endCheckedBlock(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
            if printerStatus.offline == sm_true {
                title   = "Printer Error"
                message = "Printer is offline (EndCheckedBlock)"
                break
            }
            
            title   = "Send Commands"
            message = "Success"
            
            result = true
            break
        }
        
        if error != nil {
            title   = "Printer Error"
            message = error!.description
        }
        
        if completionHandler != nil {
            completionHandler!(result, title, message)
        }
        
        return result
    }
    
    static func sendCommandsDoNotCheckCondition(commands: NSData!, portName: String!, portSettings: String!, timeout: UInt32, completionHandler: SendCompletionHandler?) -> Bool {
        var result: Bool = false
        
        var title:   String = ""
        var message: String = ""
        
        var error: NSError?
        
        let length: UInt32 = UInt32(commands.length)
        
        var array: [UInt8] = [UInt8](repeating: 0, count: commands.length)
        
        commands.getBytes(&array, length: commands.length)
        
        while true {
            guard let port: SMPort = SMPort.getPort(portName, portSettings, timeout) else {
                title   = "Fail to Open Port"
                message = ""
                break
            }
            
            defer {
                SMPort.release(port)
            }
            
            var printerStatus: StarPrinterStatus_2 = StarPrinterStatus_2()
            
            port.getParsedStatus(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
//          if printerStatus.offline == sm_true {     // Do not check condition.
//              title   = "Printer Error"
//              message = "Printer is offline (GetParsedStatus)"
//              break
//          }
            
            let startDate: NSDate = NSDate()
            
            var total: UInt32 = 0
            
            while total < length {
                let written: UInt32 = port.write(array, total, length - total, &error)
                
                if error != nil {
                    break
                }
                
                total += written
                
                if NSDate().timeIntervalSince(startDate as Date) >= 30.0 {     // 30000mS!!!
                    title   = "Printer Error"
                    message = "Write port timed out"
                    break
                }
            }
            
            if total < length {
                break
            }
            
            port.getParsedStatus(&printerStatus, 2, &error)
            
            if error != nil {
                break
            }
            
//          if printerStatus.offline == sm_true {     // Do not check condition.
//              title   = "Printer Error"
//              message = "Printer is offline (GetParsedStatus)"
//              break
//          }
            
            title   = "Send Commands"
            message = "Success"
            
            result = true
            break
        }
        
        if error != nil {
            title   = "Printer Error"
            message = error!.description
        }
        
        if completionHandler != nil {
            completionHandler!(result, title, message)
        }
        
        return result
    }
    
}
