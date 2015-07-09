//
//  RSSValidator.h
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannel;

typedef void (^SuccessBlock)(void);
typedef void (^FailureBlock)(NSError *error);

@interface RSSValidator : NSObject

- (BOOL)getChannelDetailsFromURLWithString:(NSString *)stringURL
                                 onSuccess:(SuccessBlock)successBlock
                                 onFailure:(FailureBlock)failureBlock;

@end
