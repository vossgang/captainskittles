//
//  SearchController.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DSSpeech.h"
#include "DSCard.h"
#include "DSPoint.h"

@interface SearchController : NSObject
{
    NSMutableArray          *allSpeechItems;
    NSMutableArray          *allCardItems;
    NSMutableArray          *allPointItems;
}

- (id)init;
+ (SearchController *)searchStore;

- (void)setSpeechItems:(DSSpeech *)withSpeech;
- (void)setCardItems:(DSCard *)withCard;
- (void)setPointItems:(DSPoint *)withPoint;

- (void)setSpeechArray:(NSArray *)withArray;
- (void)setCardArray:(NSArray *)withArray;
- (void)setPointArray:(NSArray *)withArray;

- (NSArray *)getSpeechArray;
- (NSArray *)getCardArray;
- (NSArray *)getPointArray;

@end
