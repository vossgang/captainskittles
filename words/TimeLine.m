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

#define CURSOR_SPEED .25

@interface TimeLine()

@property (nonatomic, strong) NSMutableArray *timeBlockViews;
@property (nonatomic, strong) Cursor *cursor;
@property (nonatomic, strong) NSTimer *iterationTimer, *refreshTimer;
@property (nonatomic) CGFloat pixelsPerSecond;
@property (nonatomic) CGFloat speechTimeRemaining, speechRunTime;

//Block Management
@property (nonatomic) NSInteger indexOfCurrentBlock;
@property (nonatomic, strong) NSMutableArray *allBlocks;

@end

@implementation TimeLine

#pragma mark - Setup Methods

+(TimeLine *)newTimeLineFromSpeech:(Speech *)speech isSubviewOf:(UIView *)view withFrame:(CGRect)frame {

    TimeLine *timeLine              = [TimeLine new];
    timeLine.timeBlockViews         = [NSMutableArray new];
    timeLine.speechTimeRemaining    = speech.runTime;
    timeLine.speechRunTime          = speech.runTime;
    timeLine.pixelsPerSecond        = (frame.size.width / speech.runTime);
    timeLine.allBlocks              = [NSMutableArray new];
    timeLine.indexOfCurrentBlock    = 0;

    //setup timeline view in proportion with reference view
    timeLine.view = [[UIView alloc] initWithFrame:frame];
    [view addSubview:timeLine.view];
    
    timeLine.view.backgroundColor = [UIColor clearColor]; //temporary assignment
    
    [timeLine setupTimeBlocksForSpeech:speech];

    [timeLine setupCursor];
    
    return timeLine;
}

#pragma mark - initial setup methods

-(void)setupTimeBlocksForSpeech:(Speech *)speech {
    
    CGFloat positionInTimeline  = 0; //x coordinate in timeline
    CGFloat width               = 0;
    
    for (Card *card in speech.cards) {
        if (!card.userEdited) {
            
            //allocate and initialize new block
            TimeBlock *newBlock = [TimeBlock newTimeBlockFromCard:card andSpeechRunTime:_speechRunTime];
            
            //calculate the new block's width
            width = (newBlock.percentageOfTimeLine * self.view.frame.size.width);
            
            //set the new blocks frame
            newBlock.frame = CGRectMake(positionInTimeline, 0, width, self.view.frame.size.height);
            
            //add block to subview & mutableArray
            [self.view addSubview:newBlock];
            [_allBlocks addObject:newBlock];
            
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
    
    for (TimeBlock *block in _allBlocks) {
        
        //calulate the new block's percentage of timeline
        block.percentageOfTimeLine = block.duration / _speechRunTime;
        
        //calculate the new block's width
        width = (block.percentageOfTimeLine * self.view.frame.size.width);
        
        [block setNeedsDisplay];
        block.frame = CGRectMake(positionInTimeline, 0, width, self.view.frame.size.height);
        [block setNeedsDisplay];
   
        //advance x coordinate in timeline
        positionInTimeline += width;
        
    }
}

-(void)advanceCursor {
    
    TimeBlock *currentBlock = _allBlocks[_indexOfCurrentBlock];
    if ((currentBlock.frame.origin.x + currentBlock.frame.size.width) < (_cursor.frame.origin.x + (_pixelsPerSecond * 4))) {
        
        //add one second to the current blocks duration
        currentBlock.duration = currentBlock.duration + 1.0;
        
        for (TimeBlock *block in _allBlocks) {
            NSLog(@"%f", block.duration);
            
        }
//        //get pending block count
//        int pendingBlockCount = 0;
//        for (TimeBlock *block in _allBlocks)
//            if (block.state == pending) pendingBlockCount++;
    
        
        //new block durration = oldblock duration minus (oldblock duration / totaltime remainin)
        
        //subtract the 1 second overage from the time duration of the remaining blocks
        for (TimeBlock *block in _allBlocks) {
            if (block.state == pending) {
                NSLog(@"%f", block.duration - (block.duration / _speechTimeRemaining));
                block.duration = block.duration - (block.duration / _speechTimeRemaining);
            }
        }
        
    }
    
    CGFloat newX = self.cursor.frame.origin.x + _pixelsPerSecond;
    
    [UIView animateWithDuration:.25 animations:^{
        _cursor.alpha += .1;
        
        self.cursor.frame = CGRectMake(newX, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
        [self redrawTimeLine];
    } completion:^(BOOL finished) {
        
    }];
    
    --_speechTimeRemaining;
    if(_speechTimeRemaining == 3) [_iterationTimer invalidate];
    
}

-(void)refreshAllViews {
    for (UIView *view in self.view.subviews) {
        [view setNeedsDisplay];
    }
}

#pragma mark - TimeLine API

-(void)startTimer {
    
    TimeBlock *currentBlock = _allBlocks[_indexOfCurrentBlock];
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


-(void)advanceToNextBlock {
    if (_allBlocks[_indexOfCurrentBlock+1]) {
        TimeBlock *currentBlock = _allBlocks[_indexOfCurrentBlock];
        currentBlock.state      = presented;
        
        //if the current block has time remaining in it's duration, deduct it, and add it to the remaining blocks
        if (currentBlock) {
            
        }
        
        _indexOfCurrentBlock++;
        currentBlock            = _allBlocks[_indexOfCurrentBlock];
        currentBlock.state      = presenting;
        
    }
}


-(void)advanceToBlockAtIndex:(NSInteger)index {
    
    if (!_allBlocks[index]) return;
    
    //the previous block is no longer presenting
    TimeBlock *currentBlock = _allBlocks[_indexOfCurrentBlock];
    currentBlock.state      = presented;
    
    TimeBlock *nextBlock    = _allBlocks[index];
    nextBlock.state         = presenting;
        
    //animate the cursor's transition to the new block
    CGFloat newX = currentBlock.frame.origin.x;
    [UIView animateWithDuration:1 animations:^{
        self.cursor.frame = CGRectMake(newX, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
    } completion:^(BOOL finished) {
            
        //recalculate time for all blocks
        [self recalculateTimePercentagesForAllBlocks];
            
        //redraw timeline
        [self redrawTimeLine];
            
        //animate the cursor back to it's tracking position at start of _current block if needed
    }];
}



-(void)recalculateTimePercentagesForAllBlocks {

}

#pragma mark - helper methods

-(NSInteger)numberOfincompleteBlocks {
    NSInteger incompleteBlocks = 0;
    for (TimeBlock *block in self.view.subviews) {
        if (!block.state) {
            incompleteBlocks++;
        }
    }
    
    return incompleteBlocks;
}



/*
-(CGFloat)timeRemainingForBlockAtIndex:(NSInteger)index {
    if ([[[self.view subviews] objectAtIndex:index] isKindOfClass:[TimeBlock class]]) {
        TimeBlock *timeBlock = [[self.view subviews] objectAtIndex:index];
        return timeBlock.timeRemaining;
    }
    
    return 0;
}
 */


@end
