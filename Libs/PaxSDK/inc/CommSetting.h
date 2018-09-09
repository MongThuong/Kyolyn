//
//  CommSetting.h
//
//  Created by admin on 5/28/13.
//  Copyright (c) 2013 paxhz. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @abstract commSetting manages the configuration information, including communication parameters etc.
 */
@interface CommSetting : NSObject

/**
 * Communication type.
 * value can be "UART","TCP", "BLUETOOTH"
 * default to "UART"<br>
 */
@property (nonatomic, assign) NSString* commType;
/**
 * Transaction time out.
 * <p>-1: no timeout, but -1 only valid for "UART" and "TCP", -default<br>
 * >0 wait n millisecond to timeout.<br>
 * measured in 1ms
 */
@property (nonatomic, assign) NSString* timeout;
/**
 * Serial Port device name
 * <p>value is "COMx" x is the number 1-6<br>
 * default to "COM1"<br>
 * valid only while CommType is UART
 */
@property (nonatomic, assign) NSString* serialPort;
/**
 * POS Terminal IP address
 * <p>For example "192.168.1.1"<br>
 * valid only while CommType is ETHERNET<br>
 */
@property (nonatomic, assign) NSString* destIP;
/**
 * Terminal port number
 * <p>value is "1" ~"65535"<br>
 * valid only while CommType is ETHERNET<br>
 */
@property (nonatomic, assign) NSString* destPort;
/**
 * Terminal bluetooth mac address
 * <p>For example is "00:40:6E:8A" "<br>
 * valid only while CommType is "BLUETOOTH"<br>
 */
@property (nonatomic, assign) NSString* bluetoothAddr;


/*!
 @abstract get MposApiConfigManager shared instance
 @result
 MposApiConfigManager shared instance
 */
+ (id)sharedInstance;

/*!
 @abstract load saved configuration
 */
- (void)load;

/*!
 @abstract save configuration
 */
- (void)save;

+ (BOOL)isValidIP:(NSString *)ipAddress;

@end
