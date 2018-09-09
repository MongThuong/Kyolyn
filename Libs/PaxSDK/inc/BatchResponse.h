//
//  BatchResponse.h
//  PosLink
//
//  Created by sunny on 15-12-18.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatchResponse : NSObject

/**
 * Result code of transaction.
 * <p>Used to determine results of transaction.<br>
 */
@property (nonatomic) NSString*ResultCode;
/**
 * Result Txt of transaction.
 */
@property (nonatomic) NSString*ResultTxt;
/**
 * Credit transaction total counts
 * <p>Note:Doesn't contain void and auth transaction count<br>
 */
@property (nonatomic) NSString*CreditCount;
/**
 * Credit transaction total amount
 * <p>Note:Doesn't contain void and auth transaction amount<br>
 */
@property (nonatomic) NSString*CreditAmount;
/**
 * Debit transaction total counts
 */
@property (nonatomic) NSString*DebitCount;
/**
 * Debit transaction total amount
 */
@property (nonatomic) NSString*DebitAmount;
/**
 * EBT transaction total counts
 * <p>Include EBT_FOODSTAMP and EBT_CASHBENEFIT<br>
 */
@property (nonatomic) NSString*EBTCount;
/**
 * EBT transaction total amount
 * <p>Include EBT_FOODSTAMP and EBT_CASHBENEFIT<br>
 */
@property (nonatomic) NSString*EBTAmount;
/**
 * Gift transaction total counts
 */
@property (nonatomic) NSString*GiftCount;
/**
 * Gift transaction total Amount
 */
@property (nonatomic) NSString*GiftAmount;
/**
 * Loyalty transaction total counts
 */
@property (nonatomic) NSString*LoyaltyCount;
/**
 * Loyalty transaction total amount
 */
@property (nonatomic) NSString*LoyaltyAmount;
/**
 * Cash transaction total counts
 */
@property (nonatomic) NSString*CashCount;
/**
 * Cash transaction total amount
 */
@property (nonatomic) NSString*CashAmount;
/**
 * CHECK transaction total counts
 */
@property (nonatomic) NSString*CHECKCount;
/**
 * CHECK transaction total amount
 */
@property (nonatomic) NSString*CHECKAmount;
/**
 * Time/date stamp of transaction
 * <p>The date time, YYYYMMDDhhmmss<br>
 */
@property (nonatomic) NSString*Timestamp;
/**
 * Terminal ID
 * <p> If terminal id exists, this field is mandatory.<br>
 */
@property (nonatomic) NSString*TID;
/**
 * Merchant ID
 * <p> If merchant id exists, this field is mandatory.<br>
 */
@property (nonatomic) NSString*MID;
/**
 * Host returns trace number.
 * <p> If host returns it, this field is mandatory and it needs to be printed on the receipt.<br>
 */
@property (nonatomic) NSString*HostTraceNum;
/**
 * Host returns batch number.
 * <p> If host returns it, this field is mandatory.<br>
 */
@property (nonatomic) NSString*BatchNum;
/**
 * Returns the transaction auth code from the payment processor
 */
@property (nonatomic) NSString*AuthCode;
/**
 * Payment processing host reference number
 */
@property (nonatomic) NSString*HostCode;
/**
 * Payment processing host response
 */
@property (nonatomic) NSString*HostResponse;
/**
 * Host or gateway message.
 */
@property (nonatomic) NSString*Message;

/**
 * Total number of new SAF records follow the SAF indicator
 */
@property (nonatomic) NSString*SAFTotalCount;

/**
 * Total amount of new SAF records follow the SAF indicator
 */
@property (nonatomic) NSString*SAFTotalAmount;

/**
 * Number of successful approved uploaded record
 */
@property (nonatomic) NSString*SAFUploadedCount;

/**
 * Number of successful approved uploaded record
 */
@property (nonatomic) NSString*SAFUploadedAmount;

/**
 * Number of failed record during the upload process
 */
@property (nonatomic) NSString*SAFFailedCount;

/**
 * Number of total record in failed Database after the upload process
 */
@property (nonatomic) NSString*SAFFailedTotal;

/**
 * Total number of records deleted
 */
@property (nonatomic) NSString*SAFDeletedCount;

/**
 * Transaction number for failed trans in terminal database during the BATCH uploading
 * process for NON SAF trans.
 */
@property (nonatomic) NSString*BatchFailedRefNum;

/**
 * Number for failed trans in terminal database during the BATCH uploading
 * process for NON SAF trans.
 */
@property (nonatomic) NSString*BatchFailedCount;

/**
 * Catch all for additional transactional information.
 * <p>Extended data in XML format.<br>
 *  &lt;Line&gt;&lt;/Line&gt;<br>
 * It is the line message return form POS terminal.<br>
 * And there may be several elements named "Line".<br>
 */
@property (nonatomic) NSString*ExtData;


-(int)unpack:(NSArray*)dataRespArry;

@end
