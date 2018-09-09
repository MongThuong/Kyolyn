//
//  PosLink.h
//  PosLink
//
//  Created by sunny on 15-7-23.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum processType
{
    UNKNOWN,
    PAYMENT,
    MANAGE,
    REPORT,
    BATCH
}processType;

@class PaymentRequest;
@class PaymentResponse;

@class ManageRequest;
@class ManageResponse;

@class BatchRequest;
@class BatchResponse;

@class ReportRequest;
@class ReportResponse;

@class ProcessTransResult;

@interface PosLink : NSObject


/**
 * The PaymentRequest object which need to be created before assign to this property.
 **/
@property (nonatomic)PaymentRequest* paymentRequest;
/**
 * The PaymentResponse object. <br>
 * <p>You can get it directly if the ProcessTrans resultCode is OK.Otherwise ,it is null.you can't assignment for the PaymentResponse object<br>
 **/
@property (nonatomic,readonly) PaymentResponse* paymentResponse;


/**
 * The ManageRequest object which need to be created before assign to this property.
 **/
@property (nonatomic) ManageRequest* manageRequest;
@property (nonatomic,readonly) ManageResponse* manageResponse;


/**
 * The BatchRequest object which need to be created before assign to this property.
 **/
@property (nonatomic)BatchRequest* batchRequest;
@property (nonatomic,readonly) BatchResponse* batchResponse;


/**
 * The ReportRequest object which need to be created before assign to this property.
 **/
@property (nonatomic)ReportRequest* reportRequest;
@property (nonatomic,readonly) ReportResponse* reportResponse;


/**
 * To cancel last process by sending command to terminal.
 */
-(void)cancelTrans;

/**
 * Get the terminal reported integer status.
 */
-(int)getReportedStatus;

/**
 * Send message according to the input objects ,and the receive response from POS terminal and unpack it,then create the corresponding response object.
 * User should get the response items from PaymentResponse,manageResponse,BatchResponse or ReportResponse object.Notes the response object is only valid while the processTransResult.Code is OK
 */
-(ProcessTransResult*)processTrans:(processType)type;

@end
