//
//  LogManager.h
//  PosLink
//
//  Created by Li Zhengzhe on 2017/8/3.
//  Copyright © 2017年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogManager : NSObject

/*!
  get LogManager shared instance
 @result
 LogManager shared instance
 */
+ (id)sharedInstance;

/**
 * start recording log
 */
-(void)start;

/**
 * write string to log file
 * @param string to be logged
 */
-(void)writeLog: (NSString *)trace;

/**
 * read log from log file according to the date
 * @param date
 * @return the log on date
 */
-(NSString *)readLog:(NSDate *)date;

/**
 * clear all log files
 */
-(bool)clearAllLog;

/**
 * nitify to write log
 */
-(void)notifyAll;
@end
