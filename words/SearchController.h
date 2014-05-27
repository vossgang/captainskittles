//
//  SearchController.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataController.h"
#include "DSSpeech.h"
#include "DSCard.h"
#include "DSPoint.h"

@interface SearchController : NSObject
{
    NSMutableArray          *arrayOfAllWords;
    NSArray                 *arrayKeyWords;
}

- (id)init;
+ (SearchController *)searchStore;

- (void)calculateKeyWords:(DSSpeech *)withSpeech;


@end
