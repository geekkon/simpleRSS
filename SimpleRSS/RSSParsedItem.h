//
//  RSSParsedItem.h
//  SimpleRSS
//
//  Created by Dim on 11.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSParsedItem : NSObject

@property (strong, nonatomic) NSString *guid;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSDate *pubDate;

@end
