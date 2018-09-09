//
//  PaymentResponse.h
//  PosLink
//
//  Created by sunny on 15-12-18.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentResponse : NSObject

    /**
     * Returns the transaction auth code from the payment processor .
     */
    @property NSString* AuthCode;
    /**
     * Approved Amount .
     * <p>Displays the actual amount approved by the host. This could be different from the requested amount<br>
     */
    @property NSString* ApprovedAmount;
    /**
     * AVS response.
     * <p>Displays the AVS response<br>
     */
    @property NSString* AvsResponse;
    /**
     * Bogus account number.
     * <p>Two conditions:<br>
     * 1.	Displays the last 4.<br>
     * 2.	Display the full account number<br>
     * It depends on terminal configuration<br>
     */
    @property NSString* BogusAccountNum;
    /**
     * Displays the card type used.
     * <p>Card type determined by bin range. <br>
     */
    @property NSString* CardType;
    /**
     * CVV response.
     * <p>CVV response code . <br>
     */
    @property NSString* CvResponse;
    /**
     * Payment processing host reference number.
     */
    @property NSString* HostCode;
    /**
     * Payment processing host response.
     */
    @property NSString* HostResponse;
    /**
     * Host or gateway message .
     */
    @property NSString* Message;
    /**
     * Gateway reference/token number.
     */
    @property NSString* RefNum;
    /**
     * Gateway raw response.
     */
    @property NSString* RawResponse;
    /**
     * Balance remaining on card .
     */
    @property NSString* RemainingBalance;
    /**
     *  Balance extra on card .
     */
    @property NSString* ExtraBalance;
    /**
     * Original requested amount of the transaction .
     */
    @property NSString* RequestedAmount;
    /**
     * Result code of transaction. Used to determine results of transaction.
     */
    @property NSString* ResultCode;
    /**
     * Result Txt of transaction
     * <p>Review result txt for details about the transaction. <br>
     */
    @property NSString* ResultTxt;
    /**
     * Time/date stamp of transaction
     */
    @property NSString* Timestamp;
    /**
     * Catch all for additional transaction information
     * <p>Extended data in XML format. <br>
     */
    @property NSString* ExtData;

-(int)unpack:(NSArray*)data;

@end
