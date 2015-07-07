//
//  RSSParser.h
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ItemsBlock)(NSArray *items);
typedef void (^FailureBlock)(NSError *error);

@interface RSSParser : NSObject

- (void)getItemsFromURL:(NSURL *)URL
              onSuccess:(ItemsBlock)itemsBlock
              onFailure:(FailureBlock)failureBlock;

@end
