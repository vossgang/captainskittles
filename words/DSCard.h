//
//  DSCard.h
//  words
//
//  Created by seanmcneil on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSSpeech;

@interface DSCard : NSManagedObject

@property (nonatomic, retain) NSString * cardConclusion;
@property (nonatomic, retain) NSNumber * cardPoint;
@property (nonatomic, retain) NSString * cardPreface;
@property (nonatomic, retain) NSNumber * cardRuntime;
@property (nonatomic, retain) NSNumber * cardSequence;
@property (nonatomic, retain) NSNumber * cardType;
@property (nonatomic, retain) DSSpeech *toSpeech;
@property (nonatomic, retain) NSSet *fromPoint;
@end

@interface DSCard (CoreDataGeneratedAccessors)

- (void)addFromPointObject:(NSManagedObject *)value;
- (void)removeFromPointObject:(NSManagedObject *)value;
- (void)addFromPoint:(NSSet *)values;
- (void)removeFromPoint:(NSSet *)values;

@end
