//
//  RSSItemViewController.m
//  SimpleRSS
//
//  Created by Dim on 10.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSItemViewController.h"
#import "RSSItem.h"

NS_ENUM(NSInteger, UIActionSheetButtonType) {
    UIActionSheetButtonTypeOpenInSafari,
};

@interface RSSItemViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;

@end

@implementation RSSItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEEE, dd MMMM HH:mm";
    
    self.titleLabel.text = self.item.title;
    self.pubDateLabel.text = [dateFormatter stringFromDate:self.item.pubDate];
    self.infoTextView.text = self.item.info;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == UIActionSheetButtonTypeOpenInSafari) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.item.link]];
    }
}

#pragma mark - Actions

- (IBAction)actionSheet:(UIBarButtonItem *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open in Safari", nil];
    
    [actionSheet showFromToolbar:nil];
}

@end
