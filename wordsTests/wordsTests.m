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
        switch (i) {
            case titleCard: {
                [card setCardTitle:@"Amazing speech title"];
                break; }
            case prefaceCard: {
                [card setCardTitle:@"Amazing speech preface"];
                [card setCardPreface:@"A speech about speaking"];
                break; }
            case bodyCard: {
                [card setCardTitle:@"My speech body"];
                DSPoint *point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"This is an amazing point"];
                [point.managedObjectContext save:nil];
                point = [[DataController dataStore] createPointItem];
                [point setToCard:card];
                [point setPointWords:@"Yet another point that is amazing"];
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
                stringToProcess = [stringToProcess stringByAppendingString:card.cardPreface];
                [arrayToProcess addObject:stringToProcess];
                break; }
            case bodyCard: {
                stringToProcess = card.cardTitle;
                for (DSPoint *point in card.fromPoint) {
                    stringToProcess = [stringToProcess stringByAppendingString:point.pointWords];
                }
                [arrayToProcess addObject:stringToProcess];
                break; }
            default:
                break;
        }
    }
    
    NSLog(@"Test output: %@",arrayToProcess);
    
    //NSString     *string     = @"This is a collection of stuff for this method to process to see if this is a winner of a method.";
    NSString *string = @"Five five fIvE five FIVE four FOUR foUR FOur two two one";
    // Create a counted set indicating how many times each word occurs in the speech
    NSCountedSet *countedSet = [NSCountedSet new];
    //TODO: Loop through speech object to get card objects
    // A string (that comes from the individual card) comes in and is fed into an array
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                // Method is called once per occurrence of a string. By using lowercase, you ignore
                                // counting word and Word as separate entries.
                                [countedSet addObject:[substring lowercaseString]];
                            }];
    // Capture the counted set objects and place them into an array for future processing
    NSMutableArray *dictArray = [NSMutableArray array];
    [countedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [dictArray addObject:@{@"object": obj,
                               @"count": @([countedSet countForObject:obj])}];
    }];
    //TODO: Remove all common words in this step
    // Sort the array from most frequent to less frequent in occurrence
    dictArray = [[dictArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] mutableCopy];
    // Construct an array of keywords
    int count = 0;
    NSMutableArray *arrayKeyWords = [NSMutableArray new];

    while (true) {

        int previousTotal = 0;
        for(id key in dictArray) {
            //NSLog(@"key=%@", key);
            int currentTotal = [[key objectForKey:@"count"] intValue];
            //NSLog(@"Total: %i",currentTotal);
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
    
}

@end
