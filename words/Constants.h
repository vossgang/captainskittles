//
//  Constants.h
//  words
//
//  Created by Christopher Cohen on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#define TIMELINE_VIEW_HEIGHT 50

//card subclasses
typedef enum : NSUInteger {
    titleCard,
    prefaceCard,
    bodyCard,
    conclusionCard,
} CardType;

typedef enum : NSUInteger {
    presented,
    presenting,
    pending,
} BlockState;

@end
