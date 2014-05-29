//
//  DSCard.h
//  words
//
//  Created by seanmcneil on 5/29/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSPoint, DSSpeech;

@interface DSCard : NSManagedObject

@property (nonatomic, retain) NSString * conclusion;
@property (nonatomic, retain) NSNumber * cardIsEntity;
@property (nonatomic, retain) NSString * preface;
@property (nonatomic, retain) NSNumber * runTime;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userEdited;
@property (nonatomic, retain) NSSet *fromPoint;
@property (nonatomic, retain) DSSpeech *speech;
@end

@interface DSCard (CoreDataGeneratedAccessors)

- (void)addFromPointObject:(DSPoint *)value;
- (void)removeFromPointObject:(DSPoint *)value;
- (void)addFromPoint:(NSSet *)values;
- (void)removeFromPoint:(NSSet *)values;

@end
