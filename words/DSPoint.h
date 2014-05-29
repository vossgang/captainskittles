//
//  DSPoint.h
//  words
//
//  Created by seanmcneil on 5/28/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSCard;

@interface DSPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * pointSequence;
@property (nonatomic, retain) NSString * pointWords;
@property (nonatomic, retain) DSCard *toCard;

@end
