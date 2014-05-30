//
//  SearchController.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataController.h"

@interface SearchController : NSObject
{
    NSMutableArray          *arrayOfAllWords;
}

- (id)init;
+ (SearchController *)searchStore;

- (NSArray *)calculateKeyWords:(Speech *)withSpeech;

- (NSArray *)searchSpeechByTitle:(NSString *)searchTerm;
- (NSArray *)searchSpeechByKeyword:(NSString *)searchTerm;

// Test only
- (NSString *)getSpeechTitle:(Speech *)withSpeech;

@end
