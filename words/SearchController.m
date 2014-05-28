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
        arrayOfKeyWords = [NSMutableArray new];
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

- (NSArray *)buildSpeechArray:(DSSpeech *)withSpeech {
    // Construct a speech into a series of strings in the array
    NSMutableArray *arrayToProcess = [NSMutableArray new];
    for (DSCard *card in withSpeech.fromCard) {
        NSString *stringToProcess;
        switch ([card.cardType intValue]) {
            case titleCard: {
                stringToProcess = card.cardTitle;
                [arrayToProcess addObject:stringToProcess];
                break; }
            case prefaceCard: {
                stringToProcess = card.cardTitle;
                stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",card.cardPreface]];
                [arrayToProcess addObject:stringToProcess];
                break; }
            case bodyCard: {
                stringToProcess = card.cardTitle;
                for (DSPoint *point in card.fromPoint) {
                    stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",point.pointWords]];
                }
                [arrayToProcess addObject:stringToProcess];
                break; }
            case conclusionCard: {
                stringToProcess = card.cardTitle;
                stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",card.cardConclusion]];
                [arrayToProcess addObject:stringToProcess];
            break; }
            default:
                break;
        }
    }
    
    return arrayToProcess;
}

- (void)calculateKeyWords:(DSSpeech *)withSpeech {
    NSArray *arrayToProcess = [self buildSpeechArray:withSpeech];
    // This string will store the contents of each speech in a single string for feeding into the counter
    NSString *stringToProcess = @"";
    // Create a counted set indicating how many times each word occurs in the speech
    NSCountedSet *countedSet = [NSCountedSet new];
    // Create an array to store the output from the NSCountedSet
    NSMutableArray *arrayFromCount = [NSMutableArray array];
    // Populate stringToProcess with the arrays derived from the speeches
    for (NSString *string in arrayToProcess) {
        stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",string]];
    }
    // Works through the speech string word by word to count word occurences
    [stringToProcess enumerateSubstringsInRange:NSMakeRange(0, [stringToProcess length])
                                        options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                         // Method is called once per occurrence of a string. By using lowercase, you ignore
                                         // counting word and Word as separate entries.
                                         
                                         // Check for words in all caps here since they are likely key points
                                         NSString *upperWord = [substring uppercaseString];
                                         if ([upperWord isEqualToString:substring] && substring.length > 1) {
                                             [countedSet addObject:substring];
                                         } else {
                                             [countedSet addObject:[substring lowercaseString]];
                                         }
                                     }];
    // Capture the counted set objects and place them into an array for future processing
    [countedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [arrayFromCount addObject:@{@"object": obj,
                               @"count": @([countedSet countForObject:obj])}];
    }];
    
    //TODO: Remove all common words in this step
    // Sort the array from most frequent to less frequent in occurrence
    arrayFromCount = [[arrayFromCount sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] mutableCopy];
    // Construct an array of keywords
    int count = 0;
    
    while (true) {
        // Check for words in ALL CAPS
        // These are automatically added to keyword search
        NSMutableArray *arrayUpper = [arrayFromCount mutableCopy];
        for(id key in arrayUpper) {
            NSString *upperCheck = [key objectForKey:@"object"];
            NSString *upperWord = [upperCheck uppercaseString];
            if ([upperCheck isEqualToString:upperWord]) {
                [arrayOfKeyWords addObject:key];
                // Remove it from dictionary to avoid double counts
                [arrayFromCount removeObject:key];
            }
        }
        // Standard check - Either the keyword array has not exceeded its limit, or the quantity of word occurences
        // matches the previous word so it is still included
        int previousTotal = 0;
        for(id key in arrayFromCount) {
            int currentTotal = [[key objectForKey:@"count"] intValue];
            if (count < 3 || previousTotal == currentTotal) {
                [arrayOfKeyWords addObject:key];
                previousTotal = currentTotal;
                count++;
            } else {
                break;
            }
        }
        break;
    }
}

- (NSArray *)returnKeywords {
    return arrayOfKeyWords;
}

@end
