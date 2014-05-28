//
//  TimeBlock.m
//  words
//
//  Created by Christopher Cohen on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "TimeBlock.h"
#import "StyleKit.h"

@implementation TimeBlock

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor    = [UIColor clearColor];
    }
    return self;
}

+(TimeBlock *)newTimeBlockFromCard:(Card *)card andSpeechRunTime:(NSTimeInterval)speechRunTime {
    TimeBlock *newBlock = [TimeBlock new];
    
    //calulate the new block's percentage of timeline
    newBlock.percentageOfTimeLine = card.runTime / speechRunTime;
    newBlock.duration             = card.runTime;
    newBlock.timeRemaining        = newBlock.duration;
    
    //set the new card's state
    newBlock.state = pending;
    
    return newBlock;
}





// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [StyleKit drawTimeBlockWithFrame:rect];
    
}



@end
