//
//  RSSItemsTableViewController.m
//  SimpleRSS
//
//  Created by Dim on 08.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSItemsTableViewController.h"
#import "RSSItemTableViewCell.h"
#import "RSSItemViewController.h"
#import "RSSDataManager.h"
#import "RSSChannel.h"
#import "RSSItem.h"

@interface RSSItemsTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) BOOL loaded;

@end

@implementation RSSItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.channel.title;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"EEEE, dd MMMM HH:mm";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    
    [self refresh:refreshControl];
    
    self.refreshControl = refreshControl;

    self.tableView.estimatedRowHeight = 45.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.loaded = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

// bug fixing for auto layout self sizing cells
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.loaded) {
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
        
        self.loaded = NO;
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
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"RSSItem"
                                      inManagedObjectContext:[RSSDataManager sharedManager].context];
    
    NSSortDescriptor *titleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pubDate"
                                                                      ascending:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel == %@", self.channel];
    
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[titleDescriptor];
    fetchRequest.predicate = predicate;
    
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

- (RSSItemTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RSSItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        RSSChannel *channel = [self.fetchedResultsController objectAtIndexPath:indexPath];
//        [[RSSDataManager sharedManager] removeChannel:channel];
//    }
//}

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
    
    if ([[segue identifier] isEqualToString:@"showItem"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RSSItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setItem:item];
    }
}

#pragma mark - Private Methods

- (void)configureCell:(RSSItemTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    RSSItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.pubDateLabel.text = [self.dateFormatter stringFromDate:item.pubDate];
    cell.titleLabel.text = item.title;
}

#pragma mark - Actions

- (void)refresh:(UIRefreshControl *)sender {
    
    [sender beginRefreshing];
    
    [[RSSDataManager sharedManager] loadItemsFromChannel:self.channel
                                              completion:^{
                                                  [sender endRefreshing];
                                              }];
}

@end
