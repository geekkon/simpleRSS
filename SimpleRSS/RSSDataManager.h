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
@class RSSItem;

typedef void (^VoidBlock)(void);

@interface RSSDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *context;

+ (RSSDataManager *)sharedManager;

- (BOOL)addChannelFromURLWithString:(NSString *)stringURL;
- (RSSChannel *)createChanel;
- (void)removeChannel:(RSSChannel *)channel;

- (void)loadItemsFromChannel:(RSSChannel *)channel completion:(VoidBlock)block;

@end
