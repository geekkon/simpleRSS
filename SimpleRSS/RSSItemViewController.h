//
//  RSSItemViewController.h
//  SimpleRSS
//
//  Created by Dim on 10.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RSSItem;

@interface RSSItemViewController : UIViewController

@property (strong, nonatomic) RSSItem *item;

@end
