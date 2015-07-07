//
//  RSSValidator.h
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannel;

typedef void (^ChannelBlock)(RSSChannel *channel);
typedef void (^FailureBlock)(NSError *error);

@interface RSSValidator : NSObject

- (void)getChannelDetailsFromURLWithString:(NSString *)stringURL
                                 onSuccess:(ChannelBlock)channelBlock
                                 onFailure:(FailureBlock)failureBlock;

@end
