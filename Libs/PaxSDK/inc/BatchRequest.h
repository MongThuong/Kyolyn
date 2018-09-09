//
//  BatchRequest.h
//  PosLink
//
//  Created by sunny on 15-12-18.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatchRequest : NSObject

/**
 * Indicate the transaction type.
 * <p>BATCHCLOSE = 1 - used to close the current batch<br>
 * FORCEBATCHCLOSE = 2 - used to force close the current batch, if host supports it.<br>
 * BATCHCLEAR = 3 - used to clear local database<br>
 * PURGEBATCH = 4 - Launches purge batch, if supported by host<br>
 * SAFUPLOAD = 5 - used to launch store and forward transacion uploading if support by host<br>
 * DELETESAFFILE = 6 - used to delete store and forward records once upload success or failed<br>
 * An Error will be returned while invoking POSLink.ProcessTrans if user set other value.<br>
 * User can assign the TransType by com.PAX.POSLink.BatchRequest.ParseTransType or assign an integer directly.<br>
 * Example:<br>
 *    BatchRequest batch = new BatchRequest();<br>
 * 	  batch.TransType = batch.ParseTransType("BATCHCLOSE");  //recommend<br>
 *    or<br>
 *    batch.TransType = 1;<br>
 *
 */
@property (nonatomic) int TransType;

/**
 *Indicate the EDC type.
 *<p>ALL = 0<br>
 *CREDIT = 1<br>
 *DEBIT = 2<br>
 *CHECK = 3<br>
 *EBT = 4  <br>
 *GIFT = 5 <br>
 *LOYALTY = 6<br>
 *CASH = 7 <br>
 *Only above value accepted, other value will be omitted.<br>
 * User can assign the EDCType by com.PAX.POSLink.BatchRequest.ParseEDCType or assign an integer directly. <br>
 * Example:
 *     BatchRequest batch = new BatchRequest(); <br>
 * 	   batch.EDCType = batch.ParseEDCType("CREDIT");  //recommend <br>
 *     or <br>
 *     batch.EDCType = 1;<br>
 */
 @property (nonatomic) int EDCType;

/**
 * Time/date stamp of transaction.
 * <p>The date time, YYYYMMDDhhmmss<br>
 */
@property (nonatomic) NSString* Timestamp;

/**
 * Store and forward upload type indicator
 * 0: New stored transaction
 * 1: Failed transaction
 * 2: All (upload/resend Failed + New records)
 * <p>Only valid when TransTYpe = SAFUPLOAD and DELETESAFFILE<br>
 */
@property (nonatomic) NSString* SAFIndicator;

/**
 * parse the String transaction type to integer type.
 * @param type could be "BATCHCLOSE","FORCEBATCHCLOSE","BATCHCLEAR"
 * @return an integer identify the TransType, or -1 if parse error.
 */
+(int) ParseTransType:(NSString*)type;

/**
 * parse the String EDC type to integer type.
 * @param type could be "ALL","CREDIT","DEBIT","CHECK","EBT","GIFT","LOYALTY","CASH"
 * @return an integer identify the EDC Type, or -1 if parse error.
 */
+(int) ParseEDCType:(NSString*) type;


-(int)pack:(NSArray**)packOutBuffer;

@end
