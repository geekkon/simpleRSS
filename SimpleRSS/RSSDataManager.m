//
//  RSSDataManager.m
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSDataManager.h"
#import "RSSValidator.h"
#import "RSSParser.h"
#import "RSSChannel.h"
#import "RSSItem.h"

@interface RSSDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation RSSDataManager

+ (RSSDataManager *)sharedManager {
    
    static RSSDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RSSDataManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Getters

- (NSManagedObjectContext *)context {
    return self.managedObjectContext;
}

#pragma mark - RSSChannel Managment

- (BOOL)addChannelFromURLWithString:(NSString *)stringURL {
    
    RSSValidator *validator = [[RSSValidator alloc] init];
    
    __weak RSSDataManager *weakSelf = self;
    
   return [validator getChannelDetailsFromURLWithString:stringURL
                                        onSuccess:^{
                                            [weakSelf saveContext];
                                        } onFailure:^(NSError *error) {
                                            NSLog(@"%@", [error localizedDescription]);
                                        }];
}

- (RSSChannel *)createChanel {
    
    RSSChannel *channel = [NSEntityDescription insertNewObjectForEntityForName:@"RSSChannel"
                                                        inManagedObjectContext:self.managedObjectContext];
    return channel;
}

- (void)removeChannel:(RSSChannel *)channel {
    
    [self.managedObjectContext deleteObject:channel];
    
    [self saveContext];
}

#pragma mark - RSSItem Managment

- (void)loadItemsFromChannel:(RSSChannel *)channel completion:(CompletionBlock)block {
    
    RSSParser *parser = [[RSSParser alloc] init];
    
    __weak RSSDataManager *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [parser getItemsFromChanel:channel
                         onSuccess:^{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 
                                 [weakSelf saveContext];
                                 
                                 if (block) {
                                     block();
                                 }
                             });
                         }
                         onFailure:^(NSError *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 
                                 NSLog(@"%@", [error localizedDescription]);
                                 
                                 if (block) {
                                     block();
                                 }
                             });
                         }];
    });
}

- (RSSItem *)createItemInChannel:(RSSChannel *)channel {
    
    RSSItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"RSSItem"
                                                        inManagedObjectContext:self.managedObjectContext];
    item.channel = channel;
    return item;
}

- (BOOL)foundGuid:(NSString *)guid inLocalChannelStore:(RSSChannel *)channel {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"RSSItem"
                                      inManagedObjectContext:[RSSDataManager sharedManager].context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel == %@ AND guid == %@", channel, guid];
    
    fetchRequest.predicate = predicate;
    
    NSError *requestError = nil;
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    return [resultArray count];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimpleRSS" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SimpleRSS.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {
    
    NSError *error = nil;
    
    BOOL successful = [self.managedObjectContext save:&error];
    
    if (!successful) {
        [NSException raise:@"Error saving" format:@"Reason : %@", [error localizedDescription]];
    }
}

@end
