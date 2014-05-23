//
//  Card.h
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Speech.h"

//card subclasses
typedef enum : NSUInteger {
    titleCard,
    prefaceCard,
    bodyCard,
    conclusionCard,
} CardType;

@interface Card : NSObject

@property (nonatomic) CardType type;
@property (nonatomic, readwrite) BOOL userEdited;

@property (nonatomic, strong) NSMutableArray *points; //contains points as strings
@property (nonatomic, strong) NSString *title, *preface, *conclusion;
@property (nonatomic) NSTimeInterval runTime, timeRemaning;
@property (nonatomic, weak)   Speech *speech;

+(id)newTitleCardForSpeech:(Speech *)speech;
+(id)newPrefaceCardForSpeech:(Speech *)speech;
+(id)newBodyCardForSpeech:(Speech *)speech;
+(id)newConclusionCardForSpeech:(Speech *)speech;

@end
