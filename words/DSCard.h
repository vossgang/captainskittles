//
//  DSCard.h
//  words
//
//  Created by seanmcneil on 5/28/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSPoint, DSSpeech;

@interface DSCard : NSManagedObject

@property (nonatomic, retain) NSString * cardConclusion;
@property (nonatomic, retain) NSString * cardPreface;
@property (nonatomic, retain) NSNumber * cardRuntime;
@property (nonatomic, retain) NSNumber * cardSequence;
@property (nonatomic, retain) NSString * cardTitle;
@property (nonatomic, retain) NSNumber * cardType;
@property (nonatomic, retain) NSNumber * cardIsEntity;
@property (nonatomic, retain) NSSet *fromPoint;
@property (nonatomic, retain) DSSpeech *speech;
@end

@interface DSCard (CoreDataGeneratedAccessors)

- (void)addFromPointObject:(DSPoint *)value;
- (void)removeFromPointObject:(DSPoint *)value;
- (void)addFromPoint:(NSSet *)values;
- (void)removeFromPoint:(NSSet *)values;

@end
