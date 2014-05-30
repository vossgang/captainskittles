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
#import "Constant.h"
#import "Cursor.h"
#import "Colorizer.h"
#import "SpeechController.h"

#define CURSOR_SPEED .25

@interface TimeLine()

//copy of speech
@property (nonatomic, strong) Speech *speech;

@property (nonatomic, strong) NSMutableArray *timeBlockViews;
@property (nonatomic, strong) Cursor *cursor;
@property (nonatomic, strong) NSTimer *iterationTimer, *refreshTimer;
@property (nonatomic) CGFloat speechTimeRemaining, speechRunTime;
@property (nonatomic, strong) NSArray *lifeCycleColors;
@property (nonatomic) CGFloat cursorTravel;

//start/stop
@property (nonatomic, weak) UIView *superView;
@property (nonatomic) CGRect timeLineFrame;
@property (nonatomic, strong) NSDate *startTime;

//Block Management
@property (nonatomic) NSInteger indexOfCurrentBlock, indexOfPreviousBlock;
@property (nonatomic, strong) NSMutableArray *blocks;
@property (nonatomic) CGFloat timeLineWidth;
@property (nonatomic, strong) NSDate *startOfCurrentBlock;


@end

@implementation TimeLine

#pragma mark - Setup Methods

+(TimeLine *)newTimeLineFromSpeech:(Speech *)speech isSubviewOf:(UIView *)view withFrame:(CGRect)frame
{
    TimeLine *timeLine              = [TimeLine new];
    
    //setup timelineSpeechCopy
    timeLine.speech                 = speech;
    
    timeLine.timeLineWidth          = frame.size.width;
    timeLine.timeBlockViews         = [NSMutableArray new];
    timeLine.speechTimeRemaining    = [SpeechController calculateTotalTime:speech];
    timeLine.speechRunTime          = [SpeechController calculateTotalTime:speech];
    timeLine.blocks                 = [NSMutableArray new];
    timeLine.indexOfCurrentBlock    = 0;
    timeLine.indexOfPreviousBlock   = 0;
    timeLine.lifeCycleColors        = @[[UIColor colorWithRed:0.36 green:0.71 blue:0.26 alpha:1],
                                        [UIColor colorWithRed:0.84 green:0.58 blue:0 alpha:1],
                                        [UIColor colorWithRed:1 green:.2 blue:.2 alpha:1] ];
    
    //setup timeline view in proportion with reference view
    timeLine.view = [[UIView alloc] initWithFrame:frame];
    [view addSubview:timeLine.view];
    
    timeLine.view.backgroundColor = [UIColor clearColor]; //temporary assignment
    [timeLine drawTimeLineForSpeech:speech];
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

#pragma mark - Setup Methods

-(void)drawTimeLineForSpeech:(Speech *)speech {
    
    CGFloat positionInTimeline  = 0; //x coordinate in timeline
    CGFloat width               = 0;
    
    int index = 0;
    
    for (Card *card in speech.cards) {
        if (card.userEdited) {
            
            //allocate and initialize new block
            TimeBlock *newBlock = [TimeBlock newTimeBlockFromCard:card andSpeechRunTime:_speechRunTime];
            
            //calculate the new block's width
            width = (newBlock.percentageOfTimeLine * _timeLineWidth);
            
            //set the new blocks frame
            newBlock.frame                  = CGRectMake(positionInTimeline, 0, width, self.view.frame.size.height);
            newBlock.associatedCardIndex    = index;
            
            //add block to subview & mutableArray
            [self.view addSubview:newBlock];
            [_blocks addObject:newBlock];
            
            //advance x coordinate in timeline
            positionInTimeline += width;
        }
        
        index++;
    }
    
}

-(void)setupCursor {
    //setup timeLine cursor
    self.cursor = [[Cursor alloc] initWithFrame:CGRectMake(0, 0, 16, self.view.frame.size.height)];
    
    [self.view addSubview:self.cursor];
}

#pragma mark - Cursor

- (void)redrawTimeLine {
    
    //redraw timeline
    CGFloat positionInTimeline  = 0; //x coordinate in timeline
    CGFloat width               = 0;
    
    for (TimeBlock *block in _blocks) {
        
        //calculate the new block's width
        width = ((block.duration / _speechRunTime) * _timeLineWidth);
        
        block.frame = CGRectMake(positionInTimeline, 0, width, self.view.frame.size.height);
        [block setNeedsDisplay];
        
        //advance x coordinate in timeline
        positionInTimeline += width;
    }
}

-(void)animateCursorTraversal
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        usleep(1000000/24);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.cursor.center = CGPointMake(_cursor.center.x + _cursorTravel, self.cursor.center.y);
            [self animateCursorTraversal];
        }];
    }];
    
}

/***************************************************
 This method is called recursivly 24 times a second;
 It recomposes the timeline only when needed.
 ***************************************************/
-(void)timeLineRenderLoop {
    
    //if the entire speech run time has elapsed, end recursion cycle and return
    if ([_startTime timeIntervalSinceNow] > _speechRunTime) return;

    TimeBlock *currentBlock = [self getPointerToPresentingBlock];
    
    CFTimeInterval timeSinceStartOfBlock = [[NSDate date] timeIntervalSinceDate:_startOfCurrentBlock];
    CFTimeInterval timeRemainingForCurrentBlock = currentBlock.duration - timeSinceStartOfBlock;
    

    if (timeRemainingForCurrentBlock < 0) {
        [self reCalcPendingPercentofDuration];
        currentBlock.duration = timeSinceStartOfBlock;
        for (TimeBlock *block in _blocks) {
            if (block.state == pending) {
                block.duration += (timeRemainingForCurrentBlock * block.percentageOfTimeRemaining);
            }
        }
        [self redrawTimeLine];
    }
    
    
    
    [[NSOperationQueue new] addOperationWithBlock:^{
        usleep(1000000 / 24);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ [self timeLineRenderLoop]; }];
    }];
}


-(void)reCalcPendingPercentofDuration
{
    NSTimeInterval remainingTime = 0;
    for (TimeBlock *block in _blocks) {
        if (block.state == pending) {
            remainingTime += block.duration;
        }
    }
    
    for (TimeBlock *block in _blocks) {
        if (block.state == pending) {
            block.percentageOfTimeRemaining = block.duration / remainingTime;
        }
    }

}


-(void)initializeBlockStates {
    
    //set all block states to 'pending'
    for (TimeBlock *block in _blocks) block.state = pending;
    
    //set first block state to 'presenting'
    TimeBlock *currentBlock = [_blocks firstObject];
    currentBlock.state      = presenting;
}

-(void)setStartTime {
    _startTime = [NSDate date];
}

#pragma mark - TimeLine API

-(void)start {
    _cursor.alpha           = 1;
    _cursorTravel           = _timeLineWidth / (_speechRunTime * 24);
    _startOfCurrentBlock    = [NSDate date];

    [self animateCursorTraversal];
    [self setStartTime];
    [self initializeBlockStates];
    [self timeLineRenderLoop];
}

-(void)stop {
    [self drawTimeLineForSpeech:_speech];
    [self setupCursor];
}


-(void)advanceToNextBlock {
    
    TimeBlock *currentBlock = [self getPointerToPresentingBlock];
    
    CFTimeInterval timeSinceStartOfBlock = [[NSDate date] timeIntervalSinceDate:_startOfCurrentBlock];
    CFTimeInterval timeRemainingForCurrentBlock = currentBlock.duration - timeSinceStartOfBlock;
    

    if (timeRemainingForCurrentBlock > 0) {
        [self reCalcPendingPercentofDuration];
        currentBlock.duration = timeSinceStartOfBlock;
        for (TimeBlock *block in _blocks) {
            if (block.state == pending) {
                block.duration += (timeRemainingForCurrentBlock * block.percentageOfTimeRemaining);
            }
        }
        [self redrawTimeLine];
    }
    
    
    TimeBlock *block;

    _startOfCurrentBlock = [NSDate date];
    
    //iterate through the 'blocks' array, stoping at the second to last object in the index
    for (int i = 0; i < _blocks.count-1; i++) {
        
        block = [_blocks objectAtIndex:i];
        
        //if the block's state is 'presenting', change current state to 'presented'
        if (block.state == presenting) {
            
            block.state = presented;
            
            //point to the next block in the array and change it's state to 'presenting'
            block       = [_blocks objectAtIndex:i+1];
            block.state = presenting;
            
            return; //all done here
        }
    }

}


#pragma mark - helper methods

-(void)refactorTimeline {
    for (UIView *view in self.view.subviews) {
        [view setNeedsDisplay];
    }
}

-(void)calculatePercentageOfRemainingForAllPendingBlocks{
    for (TimeBlock *block in _blocks) {
        if (block.state == pending) {
            block.percentageOfTimeRemaining = block.duration / [self durationSumOfPendingBlocks];
        }
    }
}

-(TimeBlock *)getPointerToPresentingBlock {
    
    for (TimeBlock *block in _blocks) if (block.state == presenting) return block;
    
    return [TimeBlock new];
}

/****************************************
 This method returns the distance between
 the cursor center point and the end of
 the presenting block.
 ****************************************/
-(CGFloat)cursorDistanceFromPresentingBlock {
    TimeBlock *presentingBlock = [self getPointerToPresentingBlock];
    return (_cursor.center.x - (presentingBlock.frame.origin.x + presentingBlock.frame.size.width));
}

-(CGFloat)durationSumOfPendingAndPresentingBlocks
{
    [self recalculateDurationsForAllBlocks];
    CGFloat pendingBlockDurationSum;
    
    for (TimeBlock *block in _blocks) {
        if (block.state == pending || block.state == presenting) pendingBlockDurationSum += block.duration;
    }
    return pendingBlockDurationSum;
}

-(CGFloat)durationSumOfPendingBlocks
{
    [self recalculateDurationsForAllBlocks];
    CGFloat pendingBlockDurationSum;
    
    for (TimeBlock *block in _blocks) {
        if (block.state == pending) pendingBlockDurationSum += block.duration;
    }
    return pendingBlockDurationSum;
}

-(void)recalculateDurationsForAllBlocks
{
    for (TimeBlock *block in _blocks) block.duration = block.percentageOfTimeLine * _speechRunTime;
}

@end
