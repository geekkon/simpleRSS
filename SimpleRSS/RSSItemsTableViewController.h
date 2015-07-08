//
//  RSSItemsTableViewController.h
//  SimpleRSS
//
//  Created by Dim on 08.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSChannel;

@interface RSSItemsTableViewController : UITableViewController

@property (strong, nonatomic) RSSChannel *channel;

@end
