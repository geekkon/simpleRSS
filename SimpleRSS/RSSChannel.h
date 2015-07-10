//
//  RSSChannel.h
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RSSChannel : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSSet *items;

@end
