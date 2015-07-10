//
//  RSSChannelsTableViewController.m
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSChannelsTableViewController.h"
#import "RSSItemsTableViewController.h"
#import "RSSDataManager.h"
#import "RSSChannel.h"

NS_ENUM(NSUInteger, UIAlertViewButtonType) {
    UIAlertViewButtonTypeCancel,
    UIAlertViewButtonTypeDone
};

NSString * const kApplicationDidLaunch = @"applicationDidLaunch";

@interface RSSChannelsTableViewController ()  <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation RSSChannelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kApplicationDidLaunch]) {
        
        [self addPresetChannels];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kApplicationDidLaunch];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"RSSChannel"
                                      inManagedObjectContext:[RSSDataManager sharedManager].context];
    
    fetchRequest.fetchBatchSize = 30;
    

    NSSortDescriptor *titleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                     ascending:YES];
    
    fetchRequest.sortDescriptors = @[titleDescriptor];
    
    _fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[RSSDataManager sharedManager].context
                                          sectionNameKeyPath:nil                                                   cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RSSChannel *channel = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[RSSDataManager sharedManager] removeChannel:channel];
    }
}

#pragma mark - <NSFetchedResultsControllerDelegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showChannel"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RSSChannel *channel = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setChannel:channel];
    } 
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == UIAlertViewButtonTypeDone) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (![[RSSDataManager sharedManager] addChannelFromURLWithString:textField.text]){
            [alertView dismissWithClickedButtonIndex:UIAlertViewButtonTypeDone animated:YES];
            [self showAlertWithTitle:@"Channel is not valid" andText:textField.text];
        }
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    UITextField *textField = [alertView textFieldAtIndex:0];

    return textField.text.length;
}

#pragma mark - Private Methods

- (void)addPresetChannels {
    
    [[RSSDataManager sharedManager] addChannelFromURLWithString:@"http://lenta.ru/rss"];
    [[RSSDataManager sharedManager] addChannelFromURLWithString:@"http://appleinsider.ru/feed"];
    [[RSSDataManager sharedManager] addChannelFromURLWithString:@"http://news.rambler.ru/rss/Samara/"];
    
    //
    ////    NSString *stringURL = @"http://ria.ru/export/rss2/index.xml";
    //    NSString *stringURL = @"http://news.rambler.ru/rss/Samara/";
    ////    NSString *stringURL = @"http://lenta.ru/rss";
    ////    NSString *stringURL = @"http://appleinsider.ru/feed";
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    RSSChannel *channel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = channel.title;
    cell.detailTextLabel.text = channel.channel;
}

- (void)showAlertWithTitle:(NSString *)title andText:(NSString *)text {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Done", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    
    textField.placeholder = @"URL";
    textField.text = text;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.returnKeyType = UIReturnKeyDone;
    textField.enablesReturnKeyAutomatically = YES;
    
    [alertView show];
}

#pragma mark - Actions

- (IBAction)actionAdd:(UIBarButtonItem *)sender {
    
    [self showAlertWithTitle:@"Add new channel" andText:nil];
}

@end
