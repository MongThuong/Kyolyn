//
//  Communication.h
//  PosLink
//
//  Created by xi chen on 6/16/16.
//  Copyright © 2016 pax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommunicatorDelegate;
@interface Communication : NSObject
@property (assign,nonatomic) id<CommunicatorDelegate> delegate;
-(void) fetchData;

@end

@protocol CommunicatorDelegate <NSObject>

-(void)didReceiveData:(NSData *) data;

@end
