//
//  BodyPoint.h
//  words
//
//  Created by seanmcneil on 5/29/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface BodyPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSString * words;
@property (nonatomic, retain) Card *cards;

@end
