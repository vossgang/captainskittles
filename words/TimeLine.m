//
//  TimeLine.m
//  words
//
//  Created by Christopher Cohen on 5/25/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "TimeLine.h"
#import "Speech.h"
#import "Card.h"
#import "TimeBlock.h"
#import "Constants.h"
#import "Cursor.h"
#import "Colorizer.h"

#define CURSOR_SPEED .25

@interface TimeLine()

@property (nonatomic, strong) NSMutableArray *timeBlockViews;
@property (nonatomic, strong) Cursor *cursor;
@property (nonatomic, strong) NSTimer *iterationTimer, *refreshTimer;
@property (nonatomic) CGFloat pixelsPerSecond;
@property (nonatomic) CGFloat speechTimeRemaining, speechRunTime;
@property (nonatomic, strong) NSArray *lifeCycleColors;

//start/stop
@property (nonatomic, weak) Speech *speech;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic) CGRect timeLineFrame;

//Block Management
@property (nonatomic) NSInteger indexOfCurrentBlock;
@property (nonatomic, strong) NSMutableArray *blocks;

@end

@implementation TimeLine

#pragma mark - Setup Methods

+(TimeLine *)newTimeLineFromSpeech:(Speech *)speech isSubviewOf:(UIView *)view withFrame:(CGRect)frame
{
    TimeLine *timeLine              = [TimeLine new];
    
    timeLine.timeBlockViews         = [NSMutableArray new];
    timeLine.speechTimeRemaining    = speech.runTime;
    timeLine.speechRunTime          = speech.runTime;
    timeLine.pixelsPerSecond        = (frame.size.width / speech.runTime);
    timeLine.blocks              = [NSMutableArray new];
    timeLine.indexOfCurrentBlock    = 0;
    timeLine.lifeCycleColors        = @[[UIColor colorWithRed:0.36 green:0.71 blue:0.26 alpha:1],
                                        [UIColor colorWithRed:0.84 green:0.58 blue:0 alpha:1],
                                        [UIColor colorWithRed:1 green:.2 blue:.2 alpha:1] ];

    //setup timeline view in proportion with reference view
    timeLine.view = [[UIView alloc] initWithFrame:frame];
    [view addSubview:timeLine.view];
    
    timeLine.view.backgroundColor = [UIColor clearColor]; //temporary assignment
    
    [timeLine setupTimeBlocksForSpeech:speech];

    [timeLine setupCursor];

    //make the timeline retain a weak pointer to the speech
    timeLine.speech         = speech;
    timeLine.superView      = view;
    timeLine.timeLineFrame  = frame;
    
    return timeLine;
}

-(BOOL)isInitialized {
    return _blocks.count;
}

#pragma mark - initial setup methods

-(void)setupTimeBlocksForSpeech:(Speech *)speech {
    
    CGFloat positionInTimeline  = 0; //x coordinate in timeline
    CGFloat width               = 0;
    
    for (Card *card in speech.cards) {
        if (card.userEdited) {
            
            //allocate and initialize new block
            TimeBlock *newBlock = [TimeBlock newTimeBlockFromCard:card andSpeechRunTime:_speechRunTime];
            
            //calculate the new block's width
            width = (newBlock.percentageOfTimeLine * self.view.frame.size.width);
            
            //set the new blocks frame
            newBlock.frame = CGRectMake(positionInTimeline, 0, width, self.view.frame.size.height);
            
            //add block to subview & mutableArray
            [self.view addSubview:newBlock];
            [_blocks addObject:newBlock];
            
            //advance x coordinate in timeline
            positionInTimeline += width;
        }
    }
    
}

-(void)setupCursor {
    //setup timeLine cursor
    self.cursor = [[Cursor alloc] initWithFrame:CGRectMake(-8, 0, 16, self.view.frame.size.height)];

    [self.view addSubview:self.cursor];
    
    
}

#pragma mark - Cursor

- (void)redrawTimeLine {
    //redraw timeline
    CGFloat positionInTimeline  = 0; //x coordinate in timeline
    CGFloat width               = 0;
    
    for (TimeBlock *block in _blocks) {
        
        //calulate the new block's percentage of timeline
        block.percentageOfTimeLine = block.duration / _speechRunTime;
        
        //calculate the new block's width
        width = (block.percentageOfTimeLine * self.view.frame.size.width);
        
        block.frame = CGRectMake(positionInTimeline, 0, width, self.view.frame.size.height);
        [block setNeedsDisplay];
   
        //advance x coordinate in timeline
        positionInTimeline += width;
        
    }
}

-(void)advanceCursor {

    TimeBlock *currentBlock = _blocks[_indexOfCurrentBlock];
    currentBlock.timeRemaining -= 1.0f; //decrement the time remaning
    currentBlock.color = [Colorizer colorFromTimeRemaining:currentBlock.timeRemaining withTotalTime:currentBlock.duration usingColors:_lifeCycleColors];
    
    NSLog(@"%f", currentBlock.timeRemaining);
            
    
    if ((currentBlock.frame.origin.x + currentBlock.frame.size.width) < (_cursor.frame.origin.x + (_pixelsPerSecond * 4))) {
        
        //add one second to the current blocks duration
        currentBlock.duration = currentBlock.duration + 1.0;
        
        //subtract the 1 second overage from the time duration of the remaining blocks
        for (TimeBlock *block in _blocks) {
            if (block.state == pending) block.duration = block.duration - (block.duration / _speechTimeRemaining);
        }
        
    }
    
    CGFloat newX = self.cursor.frame.origin.x + _pixelsPerSecond;
    
    [UIView animateWithDuration:.25 animations:^{
        _cursor.alpha += .1;
        
        self.cursor.frame = CGRectMake(newX, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
        [self redrawTimeLine];
    } completion:^(BOOL finished) {
        
    }];
    
    if(--_speechTimeRemaining == 3) [_iterationTimer invalidate];
    
}

#pragma mark - TimeLine API

-(void)start {
    
    TimeBlock *currentBlock = _blocks[_indexOfCurrentBlock];
    currentBlock.state = presenting;
    
    _iterationTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(advanceCursor)
                                            userInfo:nil
                                             repeats:YES];
    
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1/15
                                                     target:self
                                                   selector:@selector(refreshAllViews)
                                                   userInfo:nil
                                                    repeats:YES];
}

-(void)stop {
    [self setupTimeBlocksForSpeech:_speech];
    [self setupCursor];
}

-(void)advanceToNextBlock {
    if (_blocks[_indexOfCurrentBlock+1]) {
        TimeBlock *currentBlock = _blocks[_indexOfCurrentBlock];
        currentBlock.state      = presented;
        
        //add one second to the current blocks duration
        NSLog(@"%f", currentBlock.timeRemaining);
        CGFloat timeRemainingForCurrentBlock = currentBlock.timeRemaining;
        currentBlock.duration       = currentBlock.duration - timeRemainingForCurrentBlock;
        currentBlock.timeRemaining  = 0;
        NSLog(@"%f", currentBlock.duration);

        
        //add the overage from the time duration to the remaining blocks
        for (TimeBlock *block in _blocks) {
            if (block.state == pending) block.duration = block.duration + (timeRemainingForCurrentBlock * (block.duration / _speechTimeRemaining));
        }
        
        //increment index of currentblock
        currentBlock            = _blocks[++_indexOfCurrentBlock];
        currentBlock.state      = presenting;
        
        [UIView animateWithDuration:1 animations:^{
            [self redrawTimeLine];
        }];
    }
}

-(void)advanceToBlockAtIndex:(NSInteger)index {
    
    //if the index recieved by the method does not correspond to a valid index, return
    if (index > _blocks.count) return;
    
    //the previous block is no longer presenting; set to the 'presented' state
    TimeBlock *currentBlock = _blocks[_indexOfCurrentBlock];
    currentBlock.state      = presented;
    //store the remaining time of the current block
//    NSTimeInterval *surpluss = currentBlock.
    //deduct remaining time from the duration of the current block

    
    
    //the set the new block to the 'presenting' state
    TimeBlock *nextBlock    = _blocks[index];
    nextBlock.state         = presenting;
    
    
    
    
    //animate the cursor's transition to the new block
    CGFloat newX = currentBlock.frame.origin.x;
    [UIView animateWithDuration:1 animations:^{
        self.cursor.frame = CGRectMake(newX, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
    } completion:^(BOOL finished) {
        
        //redraw timeline
        [self redrawTimeLine];
            
        //animate the cursor back to it's tracking position at start of _current block if needed
    }];
}

#pragma mark - helper methods

-(void)refreshAllViews {
    for (UIView *view in self.view.subviews) {
        [view setNeedsDisplay];
    }
}


@end
