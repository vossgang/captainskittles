//
//  wordsTests.m
//  wordsTests
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>

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
    NSString     *string     = @"This is a collection of stuff for this method to process to see if this is a winner of a method.";
    NSCountedSet *countedSet = [NSCountedSet new];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                // Method is called once per occurrence of a string. By using lowercase, you ignore
                                // counting word and Word as separate entries.
                                [countedSet addObject:[substring lowercaseString]];
                            }];
    
    NSMutableArray *dictArray = [NSMutableArray array];
    [countedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [dictArray addObject:@{@"object": obj,
                               @"count": @([countedSet countForObject:obj])}];
    }];
    
    dictArray = [[dictArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] mutableCopy];
    
    
    NSLog(@"%@", dictArray);
}

@end
