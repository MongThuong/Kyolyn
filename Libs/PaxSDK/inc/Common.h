//
//  common.h
//  PosLink
//
//  Created by sunny on 15-7-27.
//  Copyright (c) 2015年 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SVERSION  @"1.28"

#define CH_STX  0x02
#define CH_ETX  0x03
#define CH_EOT  0x04
#define CH_ENQ  0x05
#define CH_ACK  0x06
#define CH_NAK  0x15
#define CH_FS   0x1c
#define ST_FS   @"\x1c"
#define CH_GS   0x1d
#define CH_US   0x1f
#define ST_US   @"\x1f"
#define ST_EQ   @"="

#define PAX_TENDER_ALL  0
#define PAX_TENDER_CREDIT  1
#define PAX_TENDER_DEBIT 2
#define PAX_TENDER_CHECK  3
#define PAX_TENDER_EBT_FOODSTAMP  4
#define PAX_TENDER_EBT_CASHBENEFIT 5
#define PAX_TENDER_GIFT  6
#define PAX_TENDER_LOYALTY  7
#define PAX_TENDER_CASH  8
#define PAX_TENDER_EBT  9

//#define PACKSIZE  3000
#define OFFSET  3000
#define PACKSIZE  141
#define BASESIZE  4000
//#define LIMIT  3000// modified for test purpose only
#define LIMIT  255

#define BASE  -1003
#define PACKERROR  (BASE + 0)
#define REQUESTNOTSET  (BASE + 1)
#define TENDERTYPEERROR  (BASE + 2)
#define TRANSTYPEERROR  (BASE + 3)
#define FORCEVALUEERROR  (BASE + 4)
#define NULLPTR  (BASE + 5)

#define FORMAT_BASE  0;
#define FORMAT_COPY  (FORMAT_BASE + 0)
#define FORMAT_ACCTNUM  (FORMAT_BASE + 1)
#define FORMAT_CARDTYPE  (FORMAT_BASE + 2)
#define FORMAT_BALANCE  (FORMAT_BASE + 3)
#define FORMAT_REQUESTAMT  (FORMAT_BASE + 4)
#define FORMAT_EBTVOUCHER  (FORMAT_BASE + 5)
#define FORMAT_USS  (FORMAT_BASE + 6)
#define FORMAT_REPORTTOTAL  (FORMAT_BASE + 7)
#define FORMAT_TIMESTAMP  (FORMAT_BASE + 8)
#define FORMAT_EDCTYPE  (FORMAT_BASE + 9)
#define FORMAT_PAYMENTTYPE  (FORMAT_BASE + 10)

enum TRANSFER {
    COPY, ACCTNUM, // card/check
    CARDTYPE, //
    BALANCE, // ebt types
    REQUESTAMT, // due+approvel
    EBTVOUCHER, // NEED TO know card type
    USS, // used in force batch close to support multi line in extdata
    REPORTTOTAL, // used in report->local total report
    TIMESTAMP, // 2choice 1
    EDCTYPE, // EDC TYPE for report
    PAYMENTTYPE
    // payment type
};

@interface NSString (MyString)

-(NSString*)appendWithFS:(NSString*)str;
-(NSString*)appendWithUS:(NSString*)str;

@end

@interface NSArray (MyArray)

-(NSString*)toStringSeperatedByFS;
-(NSString*)toStringSeperatedByUS;

@end

@interface Common : NSObject <NSXMLParserDelegate>{
    
    NSDictionary*EDCMap;
    NSDictionary*ManageMap;
    NSDictionary*BatchMap;
    NSDictionary*ReportMap;
    NSDictionary*PayTransMap;
    
    NSArray*slTrend;
    NSArray*slTrend_x;
    NSArray*slPayment;
    NSArray*slEDCpax2tgate;
    NSArray*slEDCpax2tgate_X;
    NSArray*slCardType;
    NSArray*slCardpax2tgate;
    NSArray*slTrans;
    NSArray*slManageTrans;
    NSArray*slBatchTrans;
    NSArray*slReportTrans;
}

+(id)sharedInstance;
-(int)parseTenderType:(NSString*)tendType;
-(int)parseTransType:(NSString*)transType;
-(int)parseManageTransType:(NSString*)type;
-(int)parseReportTransType:(NSString*)type;
-(int)parseBatchTransType:(NSString*)type;

-(int)parseEDCType:(NSString*)type;
-(int)parseCardTypeType:(NSString*)type;

-(NSString*) getPayType:(int)type;
-(NSString*)getPayTypeString:(int)type;
-(NSString*) getEDCType:(int)type;
-(NSString*) getEDCTypeString:(NSString*)type;
-(NSString*) getCardType:(int)type;
-(NSString*) getCardTypeString:(NSString*)type;

-(NSString*)getPayCommand:(int)type;
-(NSString*)getManageCommand:(int)type;
-(NSString*)getReportCommand:(int)type;
-(NSString*)getBatchCommand:(int)type;

-(NSMutableDictionary*)parseExtData:(NSString*)extData;

@end
