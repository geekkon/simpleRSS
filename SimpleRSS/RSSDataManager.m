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

- (RSSChannel *)createChanel {
    
    RSSChannel *channel = [NSEntityDescription insertNewObjectForEntityForName:@"RSSChannel"
                                                        inManagedObjectContext:self.managedObjectContext];
    return channel;
}

- (void)removeChannel:(RSSChannel *)channel {
    
    [self.managedObjectContext deleteObject:channel];
    
    [self saveContext];
}

#pragma mark - Public Methods

- (void)addChannelFromURLWithString:(NSString *)stringURL {
    
    RSSValidator *validator = [[RSSValidator alloc] init];
    
    [validator getChannelDetailsFromURLWithString:stringURL
                                        onSuccess:^(RSSChannel *channel) {

                                            [self saveContext];
                                        } onFailure:^(NSError *error) {
                                            NSLog(@"%@", [error localizedDescription]);
                                        }];
    
    
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
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {
    
    NSError *error = nil;
    
    BOOL successful = [self.managedObjectContext save:&error];
    
    if (!successful) {
        [NSException raise:@"Error saving" format:@"Reason : %@", [error localizedDescription]];
    }
}

@end