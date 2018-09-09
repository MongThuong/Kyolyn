//
//  ReportRequest.h
//  PosLink
//
//  Created by sunny on 15-12-18.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportRequest : NSObject

/**
 * Indicate the transaction type.
 * <p>LOCALTOTALREPORT =1 - used to retrieve the total count and total amount from the terminal via EDC type or card type.<br>
 * LOCALDETAILREPORT = 2 - used to retrieve the transaction detail from the terminal.<br>
 * LOCALFAILEDREPORT = 3 - Whenever a Settlement is run, there is the possibility that some of the transactions will fail during settlement. Those transactions are saved and their details can be retrieved using this message so that the merchant can directly settle the outstanding transactions with the card processor. If the record has reported, it will not reported again.<br>
 * HOSTREPORT = 4 - The ECR/PC should print the return line message "R07". This command is to get the current batch information of host..<br>
 * HISTORYREPORT = 5 - get the last batch information.<br>
 * SAFSUMMARYRPEPORT = 6 - used to summary report of store and forwar(SAF) information<br>
 * An Error will be returned  while invoking POSLink.ProcessTrans if user set other value.<br>
 * User can assign the TransType by com.PAX.POSLink.ReportRequest.ParseTransType or assign an integer directly.<br>
 * Example:<br>
 *    ReportRequest report = new ReportRequest();<br>
 * 	  report.TransType = report.ParseTransType("LOCALTOTALREPORT");  //recommend<br>
 *    or<br>
 *    report.TransType = 1;<br>
 *
 */

@property (nonatomic) int TransType;

/**
 *Indicate the EDC type.
 *<p>ALL = 0<br>
 *CREDIT = 1<br>
 *DEBIT = 2<br>
 *CHECK = 3<br>
 *EBT = 4<br>
 *GIFT = 5<br>
 *LOYALTY = 6<br>
 *CASH = 7<br>
 *Only above value accepted, other value will be omitted.<br>
 *EBT includes EBT_FOODSTAMP and EBT_CASHBENEFIT.<br>
 * User can assign the EDCType by com.PAX.POSLink.ReportRequest.ParseEDCType or assign an integer directly. <br>
 * Example:
 *     ReportRequest report = new ReportRequest(); <br>
 * 	   report.EDCType = report.ParseEDCType("CREDIT");  //recommend <br>
 *     or <br>
 *     report.EDCType = 1;<br>
 */
@property (nonatomic) int EDCType;

/**
 *Indicate the Card type.
 *<p>VISA = 1<br>
 *MASTERCARD = 2<br>
 *AMEX = 3<br>
 *DISCOVER = 4<br>
 *DINERCLUB = 5<br>
 *ENROUTE = 6<br>
 *JCB = 7<br>
 *REVOLUTIONCARD = 8<br>
 *OTHER = 9<br>
 *Only above value accepted, other value will be omitted.<br>
 *Used only TransType is LOCALDETAILREPORT/ LOCALTOTALREPORT<br>
 * User can assign the CardType by com.PAX.POSLink.ReportRequest.ParseCardType or assign an integer directly. <br>
 * Example:
 *     ReportRequest report = new ReportRequest(); <br>
 * 	   report.CardType = report.ParseCardType("MASTERCARD");  //recommend <br>
 *     or <br>
 *     report.CardType = 2;<br>
 */
@property (nonatomic) int CardType;

/**
 * Indicate the payment type.
 * <p>UNKNOWN = 0.<br>
 * AUTH = 1.<br>
 * SALE = 2.<br>
 * RETURN = 3.<br>
 * VOID = 4.<br>
 * POSTAUTH = 5.<br>
 * FORCEAUTH = 6.<br>
 * CAPTURE = 7.<br>
 * REPEATSALE = 8.<br>
 * CAPTUREALL = 9.<br>
 * ADJUST = 10.<br>
 * INQUIRY = 11.<br>
 * ACTIVATE = 12.<br>
 * DEACTIVATE = 13.<br>
 * RELOAD = 14.<br>
 * VOID SALE = 15.<br>
 * VOID RETURN = 16.<br>
 * VOID AUTH = 17.<br>
 * VOID POSTAUTH = 18.<br>
 * VOID FORCEAUTH = 19.<br>
 * VOID WITHDRAWAL = 20.<br>
 * REVERSAL = 21.<br>
 * WITHDRAWAL = 22.<br>
 * ISSUE = 23.<br>
 * CASHOUT = 24.<br>
 * REPLACE = 25.<br>
 * MERGE = 26.<br>
 * REPORTLOST = 27.<br>
 * REDEEM = 28.<br>
 * STATUS_CHECK = 29.<br>
 * SETUP = 30.<br>
 * INIT = 31.<br>
 * VERIFY = 32.<br>
 * REACTIVATE = 33.<br>
 * FORCED ISSUE = 34.<br>
 * FORCED ADD = 35.<br>
 * UNLOAD = 36.<br>
 * RENEW = 37.<br>
 * Only above value accepted, other value will be omitted.<br>
 * User can assign the PaymentType by com.PAX.POSLink.ReportRequest.ParseTransType or assign an integer directly.<br>
 * Example:<br>
 *    ReportRequest report = new ReportRequest();<br>
 * 	  report.PaymentType = report.ParseTransType("ADJUST");  //recommend<br>
 *    or<br>
 *    report.PaymentType = 10;<br>
 *
 */
@property (nonatomic) int PaymentType;
/**
 * The log index in terminal.
 * <p>Used only TransType is LOCALDETAILREPORT<br>
 */

@property (nonatomic) NSString*  RecordNum;

/**
 * Terminal reference number used for follow-up transactions.
 * <p>Used only TransType is LOCALDETAILREPORT<br>
 */
@property (nonatomic) NSString* RefNum;

/**
 * Retrieve the transaction record with the matching authorization number.
 * <p>Used only TransType is LOCALDETAILREPORT<br>
 */
@property (nonatomic) NSString* AuthCode;

/**
 * Retrieve the transaction record with the merchant reference number.
 * <p>Used only TransType is LOCALDETAILREPORT<br>
 */
@property (nonatomic) NSString* ECRRefNum;

/**
 * Store and forward upload type indicator
 * 0: New stored transaction
 * 1: Failed transaction
 * 2: All (upload/resend Failed + New records)
 * <p>Only valid when TransTYpe = SAFSUMMARYREPORT<br>
 */
@property (nonatomic) NSString* SAFIndicator;

/**
 * parse the String EDC type to integer type.
 * @param type could be "ALL","CREDIT","DEBIT","CHECK","EBT","GIFT","LOYALTY","CASH"
 * @return an integer identify the EDC Type, or -1 if parse error.
 */
+(int)ParseEDCType:(NSString*)type;


/**
 * parse the String Card type to integer type.
 * @param type could be "VISA","MASTERCARD","AMEX","DISCOVER","DINERCLUB","ENROUTE","JCB","REVOLUTIONCARD","OTHER"
 * @return an integer identify the Card Type, or -1 if parse error.
 */
+(int)ParseCardType:(NSString*)type;

/**
 * parse the String transaction type to integer type.
 * @param type could be "UNKNOWN",
 "AUTH",
 "SALE",
 "RETURN",
 "VOID",
 "POSTAUTH",
 "FORCEAUTH",
 "CAPTURE",
 "REPEATSALE",
 "CAPTUREALL",
 "ADJUST",
 "INQUIRY",
 "ACTIVATE",
 "DEACTIVATE",
 "RELOAD",
 "VOID SALE",
 "VOID RETURN",
 "VOID AUTH",
 "VOID POSTAUTH",
 "VOID FORCEAUTH",
 "VOID WITHDRAWAL",
 "REVERSAL",
 "WITHDRAWAL",
 "ISSUE",
 "CASHOUT",
 "REPLACE",
 "MERGE",
 "REPORTLOST",
 "REDEEM",
 "STATUS_CHECK",
 "SETUP",
 "INIT",
 "VERIFY"
 "REACTIVATE"
 "FORCED ISSUE"
 "FORCED ADD"
 "UNLOAD"
 "RENEW"
 * @return an integer identify the transaction Type, or -1 if parse error.
 */
+(int)ParsePaymentType:(NSString*)type;

/**
 * parse the String transaction type to integer type.
 * @param type could be "LOCALTOTALREPORT ","LOCALDETAILREPORT","LOCALFAILEDREPORT","HOSTREPORT","HISTORYREPORT"
 * @return an integer identify the TransType, or -1 if parse error.
 */
+(int)ParseTransType:(NSString*)type;


-(int)pack:(NSArray**)packOutBuffer;

@end

