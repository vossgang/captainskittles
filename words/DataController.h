//
//  DataController.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SearchController.h"
#import "DSSpeech.h"
#import "DSCard.h"
#import "DSPoint.h"

@interface DataController : NSObject
{
    // Used by application for managing Core Data
    NSManagedObjectContext  *context;
    NSManagedObjectModel    *model;
    // For managing search controller which stores results from core data
    SearchController        *searchController;
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
