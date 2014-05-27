//
//  DSSpeech.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSSpeech : NSManagedObject

@property (nonatomic, retain) NSString * speechTitle;
@property (nonatomic, retain) NSSet *fromCard;
@end

@interface DSSpeech (CoreDataGeneratedAccessors)

- (void)addFromCardObject:(NSManagedObject *)value;
- (void)removeFromCardObject:(NSManagedObject *)value;
- (void)addFromCard:(NSSet *)values;
- (void)removeFromCard:(NSSet *)values;

@end
