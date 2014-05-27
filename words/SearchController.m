//
//  SearchController.m
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SearchController.h"

@implementation SearchController

- (id)init {
    self = [super init];
    if (self) {
        // Init arrays
        allSpeechItems  = [NSMutableArray new];
        allCardItems    = [NSMutableArray new];
        allPointItems   = [NSMutableArray new];
    }
    
    return self;
}

+ (SearchController *)searchStore {
    // Create a singleton of this search controller
    static dispatch_once_t pred;
    static SearchController *searchStore = nil;
    dispatch_once(&pred, ^{
        searchStore = [SearchController new];
    });
    
    return searchStore;
}

- (void)setSpeechItems:(DSSpeech *)withSpeech {
    [allSpeechItems addObject:withSpeech];
}

- (void)setCardItems:(DSCard *)withCard {
    [allCardItems addObject:withCard];
}

- (void)setPointItems:(DSPoint *)withPoint {
    [allPointItems addObject:withPoint];
}

- (void)setSpeechArray:(NSArray *)withArray {
    allSpeechItems = nil;
    allSpeechItems = [[NSMutableArray alloc] initWithArray:withArray];
}

- (void)setCardArray:(NSArray *)withArray {
    allCardItems = nil;
    allCardItems = [[NSMutableArray alloc] initWithArray:withArray];
}

- (void)setPointArray:(NSArray *)withArray {
    allPointItems = nil;
    allPointItems = [[NSMutableArray alloc] initWithArray:withArray];
}

- (NSArray *)getSpeechArray {
    return allSpeechItems;
}

- (NSArray *)getCardArray {
    return allCardItems;
}

- (NSArray *)getPointArray {
    return allPointItems;
}

@end
