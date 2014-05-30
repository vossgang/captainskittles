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


- (void)testCreateSpeech {
    Speech *speech = [[DataController dataStore] createSpeechItem];
    
    SearchController *searchController = [SearchController new];
    [searchController searchSpeechByKeyword:@"Speechs"];
    
    [[DataController dataStore] removeSpeechCard:speech];
    NSLog(@"Speech total : %i",[[[DataController dataStore] allSpeechItems] count]);
}

@end
