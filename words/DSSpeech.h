//
//  DSSpeech.h
//  words
//
//  Created by seanmcneil on 5/29/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSCard;

@interface DSSpeech : NSManagedObject

@property (nonatomic, retain) id attribute;
@property (nonatomic, retain) NSSet *cards;
@end

@interface DSSpeech (CoreDataGeneratedAccessors)

- (void)addCardsObject:(DSCard *)value;
- (void)removeCardsObject:(DSCard *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

@end
