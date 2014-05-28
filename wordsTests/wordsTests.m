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

- (void)testGenerateKeywordSearch {
    // Generate a speech for testing
    DSSpeech *speech = [[DataController dataStore] createSpeechItem];
    // Build three cards to put into speech
    for (int i = 0; i < 3; i++) {
        DSCard *card = [[DataController dataStore] createCardItem];
        [card setCardType:[NSNumber numberWithInt:i]];
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

- (void)testSearchTitle {
    // This method will create an array based off of search terms, and then replace the search term with an array that it uses to store all
    // speech objects that match the result. Once the list is complete, it will then merge the lists and sort based off of frequency of occurence
    NSMutableArray *arrayToSearch = [[NSMutableArray alloc] initWithObjects:@"Have",@"words",@"Have words",@"Have lots of words",@"Nothing",@"Test", nil];
    // This sequence takes in the search terms provided by the user, splits them out into individual strings, and then stores the results in
    // a mutable array for processing. Once a result is derived, it will pop the string out and replace it with an array that stores the speeches
    // that contain the term(s)
    NSString *stringWithSearch = @"have words no";
    NSArray *searchTerms = [stringWithSearch componentsSeparatedByString:@" "];
    NSMutableArray *arraySearchTerms = [[NSMutableArray alloc] initWithArray:searchTerms];
    
    NSMutableArray *arraySearchObjects = [NSMutableArray new];
    
    for (NSString *search in arraySearchTerms) {
        // Create the new array for storing results
        NSMutableArray *resultArray = [NSMutableArray new];
        [arraySearchObjects addObject:resultArray];
        // Iterate through all objects (speeches) to search
        for (NSString *stringSpeechTitle in arrayToSearch) {
            // Check to see if there is an existing array on the search terms
            NSRange rangeTitleSearch = [stringSpeechTitle rangeOfString:search options:NSCaseInsensitiveSearch];
            
            if(rangeTitleSearch.location != NSNotFound)
            {
                [resultArray addObject:stringSpeechTitle];
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
        [final addObject:@{@"object": obj,
                               @"count": @([countedSet countForObject:obj])}];
    }];
    
    final = [[final sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] mutableCopy];
    
    
    // Pull out the individual values
    for(id key in final) {
        int total = [[key objectForKey:@"count"] intValue];
        NSString *speechTitle = [key objectForKey:@"object"];
    
    }
    
    NSLog(@"%@", final);
    
}

- (void)testSearchBySpeechTitle {
    // Generate a speech for testing
    DSSpeech *speech1 = [[DataController dataStore] createSpeechItem];
    DSCard *card1 = [[DataController dataStore] createCardItem];
    [card1 setCardType:[NSNumber numberWithInt:0]];
    [card1 setCardTitle:@"Amazing speech"];
    [card1 setToSpeech:speech1];
    [card1.managedObjectContext save:nil];
    [speech1.managedObjectContext save:nil];
    // Speech completely generated
    
    // Generate a speech for testing
    DSSpeech *speech2 = [[DataController dataStore] createSpeechItem];
    DSCard *card2 = [[DataController dataStore] createCardItem];
    [card2 setCardType:[NSNumber numberWithInt:0]];
    [card2 setCardTitle:@"Amazing speech title"];
    [card2 setToSpeech:speech2];
    [card2.managedObjectContext save:nil];
    [speech2.managedObjectContext save:nil];
    // Speech completely generated
    
    // Generate a speech for testing
    DSSpeech *speech3 = [[DataController dataStore] createSpeechItem];
    DSCard *card3 = [[DataController dataStore] createCardItem];
    [card3 setCardType:[NSNumber numberWithInt:0]];
    [card3 setCardTitle:@"Amazing"];
    [card3 setToSpeech:speech3];
    [card3.managedObjectContext save:nil];
    [speech3.managedObjectContext save:nil];
    // Speech completely generated
    
    // Generate a speech for testing
    DSSpeech *speech4 = [[DataController dataStore] createSpeechItem];
    DSCard *card4 = [[DataController dataStore] createCardItem];
    [card4 setCardType:[NSNumber numberWithInt:0]];
    [card4 setCardTitle:@"Amazing amazing speech title"];
    [card4 setToSpeech:speech4];
    [card4.managedObjectContext save:nil];
    [speech4.managedObjectContext save:nil];
    // Speech completely generated
    
    SearchController *search = [SearchController new];
    NSArray *arrayResults = [search searchSpeechByTitle:@"Amazing speech title"];
    
    for (id key in arrayResults) {
        DSSpeech *speech = [key objectForKey:@"object"];
        NSLog(@"Speech: %@",[search getSpeechTitle:speech]);
    }
    
    // Tear down speech objects
    [[DataController dataStore] removeManagedObject:speech1];
    [[DataController dataStore] removeManagedObject:speech2];
    [[DataController dataStore] removeManagedObject:speech3];
    [[DataController dataStore] removeManagedObject:speech4];

}

@end
