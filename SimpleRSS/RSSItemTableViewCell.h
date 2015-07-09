//
//  RSSItemTableViewCell.h
//  SimpleRSS
//
//  Created by Dim on 08.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
