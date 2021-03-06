//
//  TimeBlock.m
//  words
//
//  Created by Christopher Cohen on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//


#import "TimeBlock.h"
#import "StyleKit.h"
#import "SpeechController.h"

@implementation TimeBlock

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor            = [UIColor clearColor];
        self.color                      = [UIColor colorWithRed:0.36 green:0.71 blue:0.26 alpha:1];
        self.percentageOfTimeRemaining  = 0;
    }
    return self;
}

+(TimeBlock *)newTimeBlockFromCard:(Card *)card andSpeechRunTime:(NSTimeInterval)speechRunTime {
    TimeBlock *newBlock = [TimeBlock new];
    
    //calulate the new block's percentage of timeline
    newBlock.percentageOfTimeLine = [card.runTime doubleValue]/ speechRunTime;
    newBlock.duration             = [card.runTime doubleValue];
    newBlock.timeRemaining        = newBlock.duration;
    newBlock.originalDuration     = newBlock.duration;
    
    //set the new card's state
    newBlock.state = pending;
    
    return newBlock;
}


- (void)drawRect:(CGRect)rect
{
    [StyleKit drawTimeBlockWithFrame:rect andColor:self.color];
    
}



@end


//original code

/*
#import "TimeBlock.h"
#import "StyleKit.h"

@implementation TimeBlock

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor    = [UIColor clearColor];
        self.color              = [UIColor colorWithRed:0.36 green:0.71 blue:0.26 alpha:1];
    }
    return self;
}

+(TimeBlock *)newTimeBlockFromCard:(Card *)card andSpeechRunTime:(NSTimeInterval)speechRunTime {
    TimeBlock *newBlock = [TimeBlock new];
    
    //calulate the new block's percentage of timeline
    newBlock.percentageOfTimeLine = [card.runTime doubleValue]/ speechRunTime;
    newBlock.duration             = [card.runTime doubleValue];
    newBlock.timeRemaining        = newBlock.duration;
    
    //set the new card's state
    newBlock.state = pending;
    
    return newBlock;
}


- (void)drawRect:(CGRect)rect
{
    [StyleKit drawTimeBlockWithFrame:rect andColor:self.color];
    
}



@end
 */
