//
//  PaymentRequest.h
//  PosLink
//
//  Created by sunny on 15-12-18.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentRequest : NSObject

/**
 *Indicate the Tender type.
 *<p>ALL = 0<br>
 *CREDIT = 1<br>
 *DEBIT = 2<br>
 *CHECK = 3<br>
 *EBT_FOODSTAMP = 4  <br>
 *EBT_CASHBENEFIT = 5 <br>
 *GIFT = 6 <br>
 *LOYALTY = 7<br>
 *CASH = 8 <br>
 *EBT = 9 <br>
 *An Error will be return  while invoking POSLink.ProcessTrans if user set other value. <br>
 * User can assign the TenderType by com.PAX.POSLink.PaymentRequest.ParseTenderType or assign an integer directly. <br>
 * Example:
 *     PaymentRequest payment = new PaymentRequest(); <br>
 * 	   payment.EDCType = payment.ParseEDCType("CREDIT");  //recommend <br>
 *     or <br>
 *     payment.EDCType = 1;<br>
 */
@property (nonatomic) int TenderType;

/**
 * Indicate the transaction type.
 * <p>UNKNOWN = 0 ask the terminal to select transaction type.<br>
 * AUTH =1	Verify/Authorize a payment. Do not put in batch.<br>
 * SALE = 2	To make a purchase with a card or Echeck/ACH with a check. Puts card payment  in open batch
 * RETURN = 3	Return payment to card.<br>
 * VOID = 4	Removed a transaction from an unsettled batch.<br>
 * POSTAUTH = 5	Completes an Auth transaction.<br>
 * FORCEAUTH = 6 Forces transaction into open batch. Typically used for voice auths.<br>
 * CAPTURE = 7* .<br>
 * REPEATSALE = 8*	Performs a repeat sale, using the PnRef, on a previously processed card.<br>
 * CAPTUREALL = 9*	Performs a settlement or batch close.<br>
 * ADJUST = 10	Adjusts a previously processed transaction. Typically used for tip adjustment.<br>
 * INQUIRY = 11	Performs an inquiry to the host. Typically used to obtain the balance on a food stamp card or gift card.<br>
 * ACTIVATE = 12	Activates a payment card. Typically used for gift card activation.<br>
 * DEACTIVATE = 13	Deactivates an active card account. Typically used for gift cards.<br>
 * RELOAD = 14	Adds value to a card account. Typically used for gift cards.<br>
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
 * STATUS_CHECK = 29*.<br>
 * SETUP = 30* .<br>
 * INIT = 31* .<br>
 * VERIFY = 32 .<br>
 * REACTIVATE = 33.<br>
 * FORCED ISSUE = 34.<br>
 * FORCED ADD = 35.<br>
 * UNLOAD = 36.<br>
 * RENEW = 37.<br>
 * An Error will be returned while invoking POSLink.ProcessTrans if user set other value.<br>
 * User can assign the TransType by com.PAX.POSLink.PaymentRequest.ParseTransType or assign an integer directly.<br>
 * Example:<br>
 *    PaymentRequest payment = new PaymentRequest();<br>
 * 	  payment.TransType = payment.ParseTransType("SALE");  //recommend<br>
 *    or<br>
 *    payment.TransType = 1;<br>
 *
 */
@property (nonatomic)  int TransType;
/**
 * Transaction total amount$$$$$$CC.
 */
@property (nonatomic) NSString* Amount;
/**
 * Cash back amount$$$$$$CC.
 */
@property (nonatomic) NSString*  CashBackAmt;
/**
 * Fuel Amount $$$$$$CC.
 */
@property (nonatomic) NSString*  FuelAmt;
/**
 * Employee/clerk id.
 */
@property (nonatomic) NSString*  ClerkID;


@property (nonatomic) NSString*  Zip;
/**
 * Tip amount $$$$$$CC.
 */
@property (nonatomic) NSString*  TipAmt;
/**
 * Tax amount  $$$$$$CC.
 */
@property (nonatomic) NSString*  TaxAmt;
/**
 * Primary billing street address.
 */
@property (nonatomic) NSString* Street1;
/**
 * Backup billing street address.
 */
@property (nonatomic) NSString* Street2;
/**
 * The merchant surcharge fee, $$CC.
 * <p>If the setting in terminal of "merchant fee" is 0, this field must be NULL or 0.<br>
 * If the setting in terminal of "merchant fee" is not 0, this field can be exist or NULL, if the value is NULL, terminal will use the default value in terminal.<br>
 * Only debit sale and ebt cash benefit sale support it.<br>
 */
@property (nonatomic) NSString* SurchargeAmt;

/**
 * Purchase order number.
 */
@property (nonatomic) NSString* PONum;
/**
 * Original terminal reference number used for follow-up transactions.
 */
@property (nonatomic) NSString* OrigRefNum;

/**
 * POS system invoice/tracking number.
 */
@property (nonatomic) NSString* InvNum;
/**
 * The ECR reference number, This is an unique code in ECR side.
 */
@property (nonatomic) NSString* ECRRefNum;
/**
 * The ECR TransactionID, must be unique for each transaction sent to the host.
 */
@property (nonatomic) NSString* ECRTransID;
/**
 * Auth Code obtained via voice auth from payment host.
 */
@property (nonatomic) NSString* AuthCode;
/**
 * The file path taken to save the signature received from the terminal.
 */
@property (nonatomic) NSString* SigSavePath;
/**
 * Extended data in XML format
 */
@property (nonatomic) NSString* ExtData;


/**
 * parse the String Tender type to integer type.
 * @param type could be "ALL","CREDIT","DEBIT","CHECK","EBT_FOODSTAMP","EBT_CASHBENEFIT","GIFT","LOYALTY","CASH"
 * @return an integer identify the Tender Type, or -1 if parse error.
 */
+(int) ParseTenderType:(NSString*)type;

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
+(int) ParseTransType:(NSString*)type;

-(int)pack:(NSData**)packOutBuffer;


@end
