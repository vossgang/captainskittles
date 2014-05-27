//
//  SearchController.m
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SearchController.h"

typedef enum : NSUInteger {
    titleCard,
    prefaceCard,
    bodyCard,
    conclusionCard,
} CardType;

@implementation SearchController

- (id)init {
    self = [super init];
    if (self) {
        arrayOfAllWords = [NSMutableArray new];
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

- (void)calculateKeyWords:(DSSpeech *)withSpeech {
    // Iterate down the line to collect all of the text associated with speech
    for (DSCard *card in withSpeech.fromCard) {
        switch ([card.cardType intValue]) {
            case bodyCard:
                // Iterate through points
                break;
            default:
                // Not a body card, iterate through other fields stored on card
                break;
        }
    }
    NSString     *string     = @"This is a collection of stuff for this method to process to see if this is a winner of a method.";
    NSCountedSet *countedSet = [NSCountedSet new];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                // Method is called once per occurrence of a string. By using lowercase, you ignore
                                // counting word and Word as separate entries.
                                [countedSet addObject:[substring lowercaseString]];
                            }];
    
    NSLog(@"%@", countedSet);
}

@end
