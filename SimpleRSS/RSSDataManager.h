//
//  RSSDataManager.h
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@class RSSChannel;

@interface RSSDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *context;

+ (RSSDataManager *)sharedManager;

- (RSSChannel *)createChanel;
- (void)removeChannel:(RSSChannel *)channel;

- (BOOL)addChannelFromURLWithString:(NSString *)stringURL;



@end
