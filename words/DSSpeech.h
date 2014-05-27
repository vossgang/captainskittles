//
//  DSSpeech.h
//  words
//
//  Created by seanmcneil on 5/27/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSCard;

@interface DSSpeech : NSManagedObject

@property (nonatomic, retain) NSSet *fromCard;
@end

@interface DSSpeech (CoreDataGeneratedAccessors)

- (void)addFromCardObject:(DSCard *)value;
- (void)removeFromCardObject:(DSCard *)value;
- (void)addFromCard:(NSSet *)values;
- (void)removeFromCard:(NSSet *)values;

@end
