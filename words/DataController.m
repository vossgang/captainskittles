//
//  DataController.m
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "DataController.h"
#import "Card.h"

typedef enum : int {
    titleCard,
    prefaceCard,
    bodyCard,
    conclusionCard,
} CardType;

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

- (Speech *)createSpeechItem {
    Speech *speech;
    // Create new object and insert it into context
    speech = [NSEntityDescription insertNewObjectForEntityForName:@"Speech"
                                           inManagedObjectContext:context];
    NSError *error;
    // Create the associated cards for the speed
    [self createCardItem:speech andType:titleCard];
    [self createCardItem:speech andType:prefaceCard];
    [self createCardItem:speech andType:bodyCard];
    [self createCardItem:speech andType:conclusionCard];
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

- (Card *)createCardItem:(Speech *)withSpeech andType:(int)withcardType {
    Card *card;
    // Create new object and insert it into context
    card = [NSEntityDescription insertNewObjectForEntityForName:@"Card"
                                         inManagedObjectContext:context];
    
    // Default values for cards
    [card setUserEdited:NO];
    [card setSpeech:withSpeech];
    [card setType:[NSNumber numberWithInt:withcardType]];
    switch (withcardType) {
        case titleCard:
            [card setTitle:@"New Speech"];
            [card setRunTime:[NSNumber numberWithDouble:30.0]];
             [card setSequence:[NSNumber numberWithInt:0]];
            break;
        case prefaceCard:
            [card setTitle:@"Preface"];
            [card setRunTime:[NSNumber numberWithDouble:60.0]];
            [card setSequence:[NSNumber numberWithInt:1]];
            [card setPreface:@"A description of the scope of your speech goes here"];
            break;
        case bodyCard:
            [card setTitle:@"Main Point"];
            [card setRunTime:[NSNumber numberWithDouble:120.0]];
            [card setSequence:[NSNumber numberWithInt:2]];
            for (int i = 0; i < 5; i++) {
                NSString *words = @"";
                [self createPointItem:card andSequence:i andWords:words];
            }
            break;
        case conclusionCard:
            [card setTitle:@"Conclusion"];
            [card setRunTime:[NSNumber numberWithDouble:30.0]];
            [card setSequence:[NSNumber numberWithInt:3]];
            [card setConclusion:@"A conclusion statement for your speech goes here"];
            break;
        default:
            [card setTitle:@"Blank Entry"];
            [card setRunTime:[NSNumber numberWithDouble:0.0]];
            [card setSequence:[NSNumber numberWithInt:9999]];
            break;
    }
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

- (Card *)createBodyCard:(Speech *)withSpeech andSequence:(int)withSequence
{
    Card *card;
    // Create new object and insert it into context
    card = [NSEntityDescription insertNewObjectForEntityForName:@"Card"
                                         inManagedObjectContext:context];
    
    // Default values for cards
    [card setUserEdited:NO];
    [card setSpeech:withSpeech];
    [card setType:[NSNumber numberWithInt:2]];
    [card setSequence:[NSNumber numberWithInt:withSequence]];
    // Update the sequence on all cards ahead of this one
    for (Card *cardSort in withSpeech.cards) {
        if ([cardSort.sequence intValue] >= withSequence) {
            int newSequence = [cardSort.sequence intValue] + 1;
            card.sequence = [NSNumber numberWithInt:newSequence];
        }
    }
    
    NSError *error;
    // Save the object to context
    [card.managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    } else {
        // Reload the card array to reorder sequence values
        allCardItems = nil;
        [self loadAllItems];
    }
    
    return card;
}

- (NSArray *)allCardItems:(Speech *)withSpeech {
    allCardItems = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.predicate = [NSPredicate predicateWithFormat:@"speech = %@", withSpeech];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Card"];
    [request setEntity:e];
    
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"sequence"
                            ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!request) {
        [NSException raise:@"Fetch failed" format:@"Reason : %@", [error localizedDescription]];
    }
    allCardItems = [[NSMutableArray alloc] initWithArray:result];
    
    return allCardItems;
}

#pragma mark - Point item

- (BodyPoint *)createPointItem:(Card *)withCard andSequence:(int)withSequence andWords:(NSString *)withWords {
    BodyPoint *point;
    // Create new object and insert it into context
    point = [NSEntityDescription insertNewObjectForEntityForName:@"BodyPoint"
                                          inManagedObjectContext:context];
    [point setCards:withCard];
    [point setSequence:[NSNumber numberWithInt:withSequence]];
    [point setWords:withWords];
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

- (void)removeSpeechCard:(Speech *)withSpeech {
    NSError *error;
    // Remove the object from the context
    [context deleteObject:withSpeech];
    [withSpeech.managedObjectContext save:&error];
    allSpeechItems = nil;
    [self loadAllItems];
}

- (void)removeBodyCard:(Speech *)withSpeech andCard:(Card *)withCard {
    // Update the sequence on all cards ahead of this one
    for (Card *cardSort in withSpeech.cards) {
        if ([cardSort.sequence intValue] > [withCard.sequence intValue]) {
            int newSequence = [cardSort.sequence intValue] - 1;
            withCard.sequence = [NSNumber numberWithInt:newSequence];
        }
    }
    NSError *error;
    // Remove the object from the context
    [context deleteObject:withCard];
    [withCard.managedObjectContext save:&error];
    allCardItems = nil;
    [self allCardItems:withSpeech];
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
            NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Speech"];
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
            NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Card"];
            [request setEntity:e];
            
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"sequence"
                                    ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObject:sd]];
            
            NSError *error;
            NSArray *result = [context executeFetchRequest:request error:&error];
            if (!request) {
                [NSException raise:@"Fetch failed" format:@"Reason : %@", [error localizedDescription]];
            }
            allCardItems = [[NSMutableArray alloc] initWithArray:result];
        }
    }];
    
    NSBlockOperation *operationPoint = [NSBlockOperation blockOperationWithBlock:^{
        // Point items
        if (!allPointItems) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            //request.predicate = [NSPredicate predicateWithFormat:@"toCard = %@", ];
            NSEntityDescription *e = [[model entitiesByName] objectForKey:@"BodyPoint"];
            [request setEntity:e];
            
            NSSortDescriptor *sd = [NSSortDescriptor
                                    sortDescriptorWithKey:@"sequence"
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

