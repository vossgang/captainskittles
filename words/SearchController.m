//
//  SearchController.m
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SearchController.h"

#define kMaximumKeywordsValue 3

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

- (NSString *)getSpeechTitle:(Speech *)withSpeech {
    for (Card *card in withSpeech.cards) {
        switch ([card.type intValue]) {
            case titleCard:
                return card.title;
            default:
                return nil;
        }
    }
    
    return nil;
}

- (NSArray *)buildSpeechArray:(Speech *)withSpeech {
    // Construct a speech into a series of strings in the array
    NSMutableArray *arrayToProcess = [NSMutableArray new];
    for (Card *card in withSpeech.cards) {
        NSString *stringToProcess;
        switch ([card.type intValue]) {
            case titleCard: {
                stringToProcess = card.title;
                [arrayToProcess addObject:stringToProcess];
                break; }
            case prefaceCard: {
                stringToProcess = card.title;
                stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",card.preface]];
                [arrayToProcess addObject:stringToProcess];
                break; }
            case bodyCard: {
                stringToProcess = card.title;
                for (BodyPoint *point in card.points) {
                    stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",point.words]];
                }
                [arrayToProcess addObject:stringToProcess];
                break; }
            case conclusionCard: {
                stringToProcess = card.title;
                stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",card.conclusion]];
                [arrayToProcess addObject:stringToProcess];
            break; }
            default:
                break;
        }
    }
    
    return arrayToProcess;
}

#pragma mark - Search methods

- (NSArray *)searchSpeechByTitle:(NSString *)searchTerm {
    // This method will create an array based off of search terms, and then replace the search term with an array that it uses to store all
    // speech objects that match the result. Once the list is complete, it will then merge the lists and sort based off of frequency of occurence
    
    // Get an array of all speech titles
    NSMutableArray *arrayToSearch = [NSMutableArray new];
    for (Speech *speech in [[DataController dataStore] allSpeechItems]) {
        [arrayToSearch addObject:speech];
    }
    
    // This sequence takes in the search terms provided by the user, splits them out into individual strings, and then stores the results in
    // a mutable array for processing. Once a result is derived, it will pop the string out and replace it with an array that stores the speeches
    // that contain the term(s)
    NSArray *searchTerms = [searchTerm componentsSeparatedByString:@" "];
    NSMutableArray *arraySearchTerms = [[NSMutableArray alloc] initWithArray:searchTerms];
    
    NSMutableArray *arraySearchObjects = [NSMutableArray new];
    for (NSString *search in arraySearchTerms) {
        // Create the new array for storing results
        NSMutableArray *resultArray = [NSMutableArray new];
        [arraySearchObjects addObject:resultArray];
        // Iterate through all objects (speeches) to search
        for (Speech *speech in arrayToSearch) {
            // Check to see if there is an existing array on the search terms
            NSRange rangeTitleSearch = [[self getSpeechTitle:speech] rangeOfString:search options:NSCaseInsensitiveSearch];
            
            if(rangeTitleSearch.location != NSNotFound)
            {
                [resultArray addObject:speech];
            }
        }
    }
    NSMutableArray *arrayForCounter = [NSMutableArray new];
    
    for (NSMutableArray *array in arraySearchObjects) {
        [arrayForCounter addObjectsFromArray:array];
    }
    
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:arrayForCounter];
    
    NSMutableArray *final = [NSMutableArray array];
    [countedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [final addObject:@{@"object": obj, @"count": @([countedSet countForObject:obj])}];
    }];
    
    final = [[final sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] mutableCopy];
    // Returns an array of speech objects sorted by occurence of search terms
    return final;
}

- (NSArray *)searchSpeechByKeywords:(NSString *)searchTerm {
    // Create output array, will be synced to the number of speeches
    NSMutableArray *arrayForResults = [NSMutableArray new];
    // Create an array for each keyword the user is searching for
    // This will be used by the method to store the results in a sub-array of each speech that contains the specific word
    NSArray *searchTerms = [searchTerm componentsSeparatedByString:@" "];
    NSMutableArray *arrayOfSearchTerms = [[NSMutableArray alloc] initWithArray:searchTerms];
    // Iterate for each search term to see if there is a match against a keyword
    for (NSString *stringSearchTerm in arrayOfSearchTerms) {
        // Create a results array to store all speeches that contain the specific key word
        NSMutableArray *arrayOfTermResults = [NSMutableArray new];
        // Add this array to the output array
        [arrayForResults addObject:arrayOfTermResults];
        // Iterate through all speeches
        for (Speech *speech in [[DataController dataStore] allSpeechItems]) {
            // Now iterate through all the keywords for the specific speech
            for (NSString *stringKeyword in [self calculateKeyWords:speech]) {
                // Look for matches against keywords
                NSRange rangeKeywordSearch = [stringKeyword rangeOfString:stringSearchTerm options:NSCaseInsensitiveSearch];
                // If a match is received, then add it to the output array
                if(rangeKeywordSearch.location != NSNotFound)
                {
                    // Add to output array here
                    [arrayOfTermResults addObject:speech];
                }
            }
        }
    }
    
    // Break down results array to sort based on number of unique hits
    
    // This section will sum up the amount of times each speech was found, and then sort it accordingly
    
    return arrayForResults;
}

- (NSArray *)calculateKeyWords:(Speech *)withSpeech {
    NSMutableArray *arrayToReturn = [NSMutableArray new];
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

                                             NSString *wordStripped = [[substring componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
                                             if (![wordStripped isEqualToString:upperWord]) {
                                                 // The word contains punctuation, so add in both forms
                                                 [countedSet addObject:wordStripped];
                                             }
                                             

                                             [countedSet addObject:substring];
                                         } else {
                                             [countedSet addObject:[substring lowercaseString]];
                                         }
                                     }];
    // Capture the counted set objects and place them into an array for future processing
    [countedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [arrayFromCount addObject:@{@"object": obj, @"count": @([countedSet countForObject:obj])}];
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
                [arrayToReturn addObject:@{@"speech": withSpeech, @"keyword": key}];
                // Remove it from dictionary to avoid double counts
                [arrayFromCount removeObject:key];
            }
        }
        // Standard check - Either the keyword array has not exceeded its limit, or the quantity of word occurences
        // matches the previous word so it is still included
        int previousTotal = 0;
        for(id key in arrayFromCount) {
            NSNumber *currentTotal = [NSNumber numberWithInt:[[key objectForKey:@"count"] intValue]];
            if (count < kMaximumKeywordsValue || previousTotal == [currentTotal intValue]) {
                previousTotal = [currentTotal intValue];
                [arrayToReturn addObject:@{@"speech": withSpeech, @"keyword": key}];
                count++;
            } else {
                break;
            }
        }
        break;
    }
    
    return arrayToReturn;
}

@end
