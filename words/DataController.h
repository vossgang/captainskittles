//
//  DataController.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DSSpeech.h"
#import "DSCard.h"
#import "DSPoint.h"

@interface DataController : NSObject
{
    NSMutableArray          *allSpeechItems;
    NSMutableArray          *allCardItems;
    NSMutableArray          *allPointItems;
    // Used by application for managing Core Data
    NSManagedObjectContext  *context;
    NSManagedObjectModel    *model;
}

+ (DataController *)dataStore;
- (void)removeManagedObject:(NSManagedObject *)objectToRemove;
- (void)reloadAllItems;

- (DSSpeech *)createSpeechItem;
- (NSArray *)allSpeechItems;

- (DSCard *)createCardItem;
- (NSArray *)allCardItems;

- (DSPoint *)createPointItem;
- (NSArray *)allPointItems;

@end
