//
//  DataController.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Speech.h"
#import "Card.h"
#import "BodyPoint.h"

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

- (Speech *)createSpeechItem;
- (NSArray *)allSpeechItems;

- (Card *)createCardItem:(Speech *)withSpeech andType:(int)withcardType;
- (Card *)createBodyCard:(Speech *)withSpeech andSequence:(int)withSequence;
- (NSArray *)allCardItems;

@end
