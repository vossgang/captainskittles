//
//  wordsTests.m
//  wordsTests
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DataController.h"
#import "SearchController.h"

typedef enum : NSUInteger {
    titleCard,
    prefaceCard,
    bodyCard,
    conclusionCard,
} CardType;

@interface wordsTests : XCTestCase

@end

@implementation wordsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenerateKeywords
{
    // Generate a speech for testing
    DSSpeech *speech = [[DataController dataStore] createSpeechItem];
    // Build three cards to put into speech
    for (int i = 0; i < 3; i++) {
        DSCard *card = [[DataController dataStore] createCardItem];
        [card setCardType:[NSNumber numberWithInt:i]];
        // Speech = 5, amazing = 4, point = 3
        switch (i) {
            case titleCard: {
                [card setCardTitle:@"Amazing speech title"];
                break; }
            case prefaceCard: {
                [card setCardTitle:@"Amazing speech preface"];
                [card setCardPreface:@"A speech about speaking"];
                break; }
            case bodyCard: {
                [card setCardTitle:@"My speech body and a point"];
                DSPoint *point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"This is an amazing point in my speech"];
                [point.managedObjectContext save:nil];
                point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"Yet another point that is amazing"];
                [point.managedObjectContext save:nil];
                point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"N.S.A."];
                [point.managedObjectContext save:nil];
                break; }
            default:
                break;
        }
        [card setToSpeech:speech];
        [card.managedObjectContext save:nil];
    }
    [speech.managedObjectContext save:nil];
    // Speech completely generated
    
    // Now query speech to build an array for performing the keyword search
    NSMutableArray *arrayToProcess = [NSMutableArray new];
    speech = [[[DataController dataStore] allSpeechItems] firstObject];
    for (DSCard *card in speech.fromCard) {
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
            default:
                break;
        }
    }
    
    NSLog(@"Test output: %@",arrayToProcess);
    // ***
    // Everything prior to this is fine
    // ***
    
    // This array will hold the keywords after being assembled by the method below
    NSMutableArray *arrayKeyWords = [NSMutableArray new];
    // Create a counted set indicating how many times each word occurs in the speech
    NSCountedSet *countedSet = [NSCountedSet new];
    
    NSMutableArray *dictArray = [NSMutableArray array];
    
    NSString *stringToProcess = @"";
    for (NSString *string in arrayToProcess) {
        stringToProcess = [stringToProcess stringByAppendingString:[NSString stringWithFormat:@" %@",string]];
    }
    
    // A string (that comes from the individual card) comes in and is fed into an array
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
        [dictArray addObject:@{@"object": obj,
                               @"count": @([countedSet countForObject:obj])}];
    }];
    
    //TODO: Remove all common words in this step
    // Sort the array from most frequent to less frequent in occurrence
    dictArray = [[dictArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] mutableCopy];
    // Construct an array of keywords
    int count = 0;
    
    while (true) {
        // Check for words in ALL CAPS
        NSMutableArray *arrayUpper = [dictArray mutableCopy];
        for(id key in arrayUpper) {
            NSString *upperCheck = [key objectForKey:@"object"];
            NSString *upperWord = [upperCheck uppercaseString];
            if ([upperCheck isEqualToString:upperWord]) {
                [arrayKeyWords addObject:key];
                // Remove it from dictionary to avoid double counts
                [dictArray removeObject:key];
            }
        }
        // Standard check - Either the keyword array has not exceeded its limit, or the quantity of word occurences
        // matches the previous word so it is still included
        int previousTotal = 0;
        for(id key in dictArray) {
            int currentTotal = [[key objectForKey:@"count"] intValue];
            if (count < 3 || previousTotal == currentTotal) {
                [arrayKeyWords addObject:key];
                previousTotal = currentTotal;
                count++;
            } else {
                break;
            }
        }
        break;
    }
    NSLog(@"Array: %@",arrayKeyWords);
    
    // Testing component
    int loop = 0;
    for (id key in arrayKeyWords) {
        int count = [[key objectForKey:@"count"] intValue];
        NSString *word = [key objectForKey:@"object"];
        switch (loop) {
            case 0:
                XCTAssert(count == 1 && [word isEqualToString:@"NSA"], @"NSA is not matching up");
                break;
            case 1:
                XCTAssert(count == 5 && [word isEqualToString:@"speech"], @"Speech is not matching up");
                break;
            case 2:
                XCTAssert(count == 4 && [word isEqualToString:@"amazing"], @"Amazing is not matching up");
                break;
            case 3:
                XCTAssert(count == 3 && [word isEqualToString:@"point"], @"Point is not matching up");
                break;
            default:
                break;
        }
        loop++;
    }
    
    // Tear down speech object
    [[DataController dataStore] removeManagedObject:speech];
}

- (void)testGenerateKeywordSearch {
    // Generate a speech for testing
    DSSpeech *speech = [[DataController dataStore] createSpeechItem];
    // Build three cards to put into speech
    for (int i = 0; i < 3; i++) {
        DSCard *card = [[DataController dataStore] createCardItem];
        [card setCardType:[NSNumber numberWithInt:i]];
        // Speech = 5, amazing = 4, point = 3
        switch (i) {
            case titleCard: {
                [card setCardTitle:@"Amazing speech title"];
                break; }
            case prefaceCard: {
                [card setCardTitle:@"Amazing speech preface"];
                [card setCardPreface:@"A speech about speaking"];
                break; }
            case bodyCard: {
                [card setCardTitle:@"My speech body and a point"];
                DSPoint *point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"This is an amazing point in my speech"];
                [point.managedObjectContext save:nil];
                point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"Yet another point that is amazing"];
                [point.managedObjectContext save:nil];
                point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"NSA U.S.A"];
                [point.managedObjectContext save:nil];
                break; }
            default:
                break;
        }
        [card setToSpeech:speech];
        [card.managedObjectContext save:nil];
    }
    [speech.managedObjectContext save:nil];
    // Speech completely generated
    
    [[SearchController searchStore] calculateKeyWords:speech];
    
    NSLog(@"%@",[[SearchController searchStore] returnKeywords]);
    
    // Testing component
    int loop = 0;
    for (id key in [[SearchController searchStore] returnKeywords]) {
        int count = [[key objectForKey:@"count"] intValue];
        NSString *word = [key objectForKey:@"object"];
        switch (loop) {
            case 0:
                XCTAssert(count == 1 && [word isEqualToString:@"U.S.A"], @"U.S.A is not matching up");
                break;
            case 1:
                XCTAssert(count == 1 && [word isEqualToString:@"USA"], @"USA is not matching up");
                break;
            case 2:
                XCTAssert(count == 1 && [word isEqualToString:@"NSA"], @"NSA is not matching up");
                break;
            case 3:
                XCTAssert(count == 5 && [word isEqualToString:@"speech"], @"Speech is not matching up");
                break;
            case 4:
                XCTAssert(count == 4 && [word isEqualToString:@"amazing"], @"Amazing is not matching up");
                break;
            case 5:
                XCTAssert(count == 3 && [word isEqualToString:@"point"], @"Point is not matching up");
                break;
            default:
                break;
        }
        loop++;
    }
    
    // Tear down speech object
    [[DataController dataStore] removeManagedObject:speech];
}

@end
