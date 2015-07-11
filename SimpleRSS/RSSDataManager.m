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
#import "RSSParsedItem.h"
#import "RSSChannel.h"
#import "RSSItem.h"

@interface RSSDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) dispatch_queue_t parserQueue;

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

- (dispatch_queue_t)parserQueue {
    
    if (!_parserQueue) {
        _parserQueue = dispatch_queue_create("simple.rss.parser.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return _parserQueue;
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

- (void)loadItemsFromChannel:(RSSChannel *)channel completion:(VoidBlock)block {
    
    RSSParser *parser = [[RSSParser alloc] init];
    
    __weak RSSDataManager *weakSelf = self;
    
    dispatch_async([RSSDataManager sharedManager].parserQueue, ^{
        
        [parser getItemsFromURLWithString:channel.channel
                          completionBlock:^(BOOL success, NSArray *items, NSError *error) {
                              
                              if (success) {
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [weakSelf insertItems:items toChannel:channel withBlock:(block)];
                                  });
                                  
                              } else {
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      
                                      NSLog(@"%@", [error localizedDescription]);
                                      
                                      if (block) {
                                          block();
                                      }
                                  });
                              }
                          }];
    });
}

- (void)insertItems:(NSArray *)items toChannel:(RSSChannel *)channel withBlock:(VoidBlock)block {
    
    if (items) {
        
        for (RSSParsedItem  *parsedItem in items) {
            
            if (![self foundGuid:parsedItem.guid inLocalChannelStore:channel]) {
            
                RSSItem *item = [self createItemInChannel:channel];
                
                item.title = parsedItem.title;
                item.guid  = parsedItem.guid;
                item.link  = parsedItem.link;
                item.info  = parsedItem.info;
                item.pubDate  = parsedItem.pubDate;
                
//                [self saveContext];
            }
            
            [self saveContext];
        }
    }
 
    if (block) {
        block();
    }
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
    
    fetchRequest.fetchLimit = 1;
    
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
