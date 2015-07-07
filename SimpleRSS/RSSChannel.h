//
//  RSSChannel.h
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RSSItem;

@interface RSSChannel : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSSet *items;
@end

@interface RSSChannel (CoreDataGeneratedAccessors)

- (void)addItemsObject:(RSSItem *)value;
- (void)removeItemsObject:(RSSItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
