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

- (Speech *)createSpeechItem;
- (NSArray *)allSpeechItems;

- (Card *)createCardItem:(Speech *)withSpeech andType:(int)withcardType;
- (Card *)createBodyCard:(Speech *)withSpeech andSequence:(int)withSequence;
- (NSArray *)allCardItems:(Speech *)withSpeech;

- (Card *)moveCard:(Card *)oldCard forSpeech:(Speech *)withSpeech toSequence:(int)newSequence;


- (void)removeSpeechCard:(Speech *)withSpeech;
- (void)removeBodyCard:(Speech *)withSpeech andCard:(Card *)withCard;
- (void)reloadAllItems;

@end
