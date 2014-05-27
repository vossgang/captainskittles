//
//  DSCard.h
//  words
//
//  Created by seanmcneil on 5/27/14.
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
@property (nonatomic, retain) NSNumber * cardType;
@property (nonatomic, retain) NSString * cardTitle;
@property (nonatomic, retain) DSSpeech *toSpeech;
@property (nonatomic, retain) NSSet *fromPoint;
@end

@interface DSCard (CoreDataGeneratedAccessors)

- (void)addFromPointObject:(DSPoint *)value;
- (void)removeFromPointObject:(DSPoint *)value;
- (void)addFromPoint:(NSSet *)values;
- (void)removeFromPoint:(NSSet *)values;

@end
