//
//  DataController.m
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "DataController.h"

@implementation DataController

#pragma mark - General Core Data methods

- (id)init {
    self = [super init];
    //NSLog(@"Class: %@ Method: %s",self.class, sel_getName(_cmd));
    if (self) {
        // Read in from data store
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc=
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Identify its location on the file system
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [NSManagedObjectContext new];
        [context setPersistentStoreCoordinator:psc];
        [context setUndoManager:nil];
        [self loadAllItems];
    }
    
    return self;
}

- (NSString *)itemArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

#pragma mark - Global methods
+ (DataController *)dataStore {
    // Create a singleton of this data controller
    static dispatch_once_t pred;
    static DataController *dataStore = nil;
    dispatch_once(&pred, ^{
        dataStore = [DataController new];
    });
    
    return dataStore;
}

- (void)dealloc {
    
}

#pragma mark - Entity calls

#pragma mark - Speech item

- (DSSpeech *)createSpeechItem {
    DSSpeech *speech;
    // Create new object and insert it into context
    speech = [NSEntityDescription insertNewObjectForEntityForName:@"DSSpeech"
                                           inManagedObjectContext:context];
    NSError *error;
    // Save the object to context
    [speech.managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    } else {
        [allSpeechItems addObject:speech];
    }
    
    return speech;
}

- (NSArray *)allSpeechItems {
    return allSpeechItems;
}

#pragma mark - Card item

- (DSCard *)createCardItem {
    DSCard *card;
    // Create new object and insert it into context
    card = [NSEntityDescription insertNewObjectForEntityForName:@"DSCard"
                                         inManagedObjectContext:context];
    NSError *error;
    // Save the object to context
    [card.managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    } else {
        [allCardItems addObject:card];;
    }
    
    return card;
}

- (NSArray *)allCardItems {
    return allCardItems;
}

#pragma mark - Point item

- (DSPoint *)createPointItem {
    DSPoint *point;
    // Create new object and insert it into context
    point = [NSEntityDescription insertNewObjectForEntityForName:@"DSPoint"
                                          inManagedObjectContext:context];
    NSError *error;
    // Save the object to context
    [point.managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    } else {
        [allPointItems addObject:point];
    }
    
    return point;
}

- (NSArray *)allPointItems {
    return allPointItems;
}

#pragma mark - Core data interaction

- (void)removeManagedObject:(NSManagedObject *)objectToRemove {
    NSError *error;
    // Remove the object from the context
    [context deleteObject:objectToRemove];
    [objectToRemove.managedObjectContext save:&error];
    // Check for what kind of object it is and then remove from local array
    if ([objectToRemove isKindOfClass:[DSSpeech class]]) {
        [allSpeechItems removeObject:objectToRemove];
    };
    if ([objectToRemove isKindOfClass:[DSCard class]]) {
        [allCardItems removeObject:objectToRemove];
    };
    if ([objectToRemove isKindOfClass:[DSPoint class]]) {
        [allPointItems removeObject:objectToRemove];
    };
}

- (void)reloadAllItems {
    [allSpeechItems removeAllObjects];
    [allCardItems   removeAllObjects];
    [allPointItems   removeAllObjects];
    [self loadAllItems];
}

- (void)loadAllItems {
    NSOperationQueue *loadItemsQueue = [NSOperationQueue new];
    loadItemsQueue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *operationSpeech = [NSBlockOperation blockOperationWithBlock:^{
        // Speech items
        if (!allSpeechItems) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *e = [[model entitiesByName] objectForKey:@"DSSpeech"];
            [request setEntity:e];
            
            NSError *error;
            NSArray *result = [context executeFetchRequest:request error:&error];
            if (!request) {
                [NSException raise:@"Fetch failed" format:@"Reason : %@", [error localizedDescription]];
            }
            
            allSpeechItems = [[NSMutableArray alloc] initWithArray:result];        }
    }];
    
    NSBlockOperation *operationCard = [NSBlockOperation blockOperationWithBlock:^{
        // Card items
        if (!allCardItems) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            //request.predicate = [NSPredicate predicateWithFormat:@"toSpeech = %@", ];
            NSEntityDescription *e = [[model entitiesByName] objectForKey:@"DSCard"];
            [request setEntity:e];
            
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"cardSequence"
                                    ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObject:sd]];
            
            NSError *error;
            NSArray *result = [context executeFetchRequest:request error:&error];
            if (!request) {
                [NSException raise:@"Fetch failed" format:@"Reason : %@", [error localizedDescription]];
            }
            allCardItems = [[NSMutableArray alloc] initWithArray:result];        }
    }];
    
    NSBlockOperation *operationPoint = [NSBlockOperation blockOperationWithBlock:^{
        // Point items
        if (!allPointItems) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            //request.predicate = [NSPredicate predicateWithFormat:@"toCard = %@", ];
            NSEntityDescription *e = [[model entitiesByName] objectForKey:@"DSPoint"];
            [request setEntity:e];
            
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"pointSequence"
                                    ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObject:sd]];
            
            NSError *error;
            NSArray *result = [context executeFetchRequest:request error:&error];
            if (!request) {
                [NSException raise:@"Fetch failed" format:@"Reason : %@", [error localizedDescription]];
            }
            allPointItems = [[NSMutableArray alloc] initWithArray:result];        }
    }];
    
    // Execute all blocks against the queue in parallel
    [loadItemsQueue addOperations:
     @[operationSpeech,operationCard,operationPoint] waitUntilFinished:YES];
}


@end

