//
//  Card.h
//  words
//
//  Created by seanmcneil on 5/29/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BodyPoint, Speech;

@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * conclusion;
@property (nonatomic, retain) NSNumber * cardIsEntity;
@property (nonatomic, retain) NSString * preface;
@property (nonatomic, retain) NSNumber * runTime;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userEdited;
@property (nonatomic, retain) NSSet *points;
@property (nonatomic, retain) Speech *speech;
@end

@interface Card (CoreDataGeneratedAccessors)

- (void)addPointsObject:(BodyPoint *)value;
- (void)removePointsObject:(BodyPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
