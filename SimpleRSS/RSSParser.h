//
//  RSSParser.h
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(BOOL successful, NSArray *items, NSError *error);

@interface RSSParser : NSObject

- (void)getItemsFromURLWithString:(NSString *)string
                  completionBlock:(CompletionBlock)completionBlock;

@end