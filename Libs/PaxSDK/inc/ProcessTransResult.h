//
//  processTransResult.h
//  PosLink
//
//  Created by sunny on 15-7-23.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaymentResponse;
@class ManageResponse;
@class ReportResponse;
@class BatchResponse;

typedef enum processTransResultCode{
    
    OK,
    TIMEOUT,
    ERROR
}resultCode;

@interface ProcessTransResult : NSObject

@property resultCode code;
@property NSString *msg;

//@property PaymentResponse *paymentResponse;
//@property ManageResponse *manageResponse;
//@property ReportResponse *reportResponse;
//@property BatchResponse  *batchResponse;

-(void)clear;

@end
