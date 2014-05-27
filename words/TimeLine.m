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

@interface TimeLine()

@property (nonatomic, strong) NSMutableArray *timeBlockViews;
@property (nonatomic, strong) UIView *cursor;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) TimeBlock *currentBlock;
@property (nonatomic) CGFloat pixelsPerSecond;
@property (nonatomic) CGFloat speechTimeRemaining, speechRunTime;
@property (nonatomic) NSInteger timeBlockIndex;

@end

@implementation TimeLine

#pragma mark - Setup Methods

+(TimeLine *)newTimeLineFromSpeech:(Speech *)speech isSubviewOf:(UIView *)view {

    TimeLine *timeLine              = [TimeLine new];
    timeLine.timeBlockViews         = [NSMutableArray new];
    timeLine.speechTimeRemaining    = speech.runTime;
    timeLine.speechRunTime          = speech.runTime;
    
    //setup timeline view in proportion with reference view
    timeLine.view = [[UIView alloc] initWithFrame:CGRectMake(0, 25, view.frame.size.height, TIMELINE_VIEW_HEIGHT)];
    [view addSubview:timeLine.view];
    timeLine.view.backgroundColor = [UIColor clearColor]; //temporary assignment
    
    [timeLine setupTimeBlocksForSpeech:speech];

    [timeLine setupCursor];
    
    return timeLine;
}

-(void)setupTimeBlocksForSpeech:(Speech *)speech {
    
    CGFloat movingX = 0;
    CGFloat width   = 0;
    _pixelsPerSecond = (self.view.frame.size.width / speech.runTime);
    
    for (Card *card in speech.cards) {
        
        //calculate the new timeblock's width
        width = (_pixelsPerSecond * card.runTime);
        
        //create new timeblock
        TimeBlock *newBlock = [[TimeBlock alloc] initWithFrame:CGRectMake(movingX, 10, width, TIMELINE_VIEW_HEIGHT - 20)];
        
        //time tracking properties
        newBlock.timeAllowance  = card.runTime;
        newBlock.timeSpent      = 0;
        
        if ([[self.view.subviews lastObject] isKindOfClass:[TimeBlock class]]) {
            TimeBlock *preceedingBlock  = [self.view.subviews lastObject];
            preceedingBlock.nextBlock   = newBlock;
        }
        
        [self.view addSubview:newBlock];
        movingX += width;
        

    }
    
}

-(void)setupCursor {
    //setup timeLine cursor
    self.cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, TIMELINE_VIEW_HEIGHT)];
    self.cursor.backgroundColor = [UIColor grayColor];
    self.cursor.layer.cornerRadius = 2.5;
    self.cursor.layer.masksToBounds = YES;
    [self.view addSubview:self.cursor];
    
    
}

-(void)advanceCursor {
    
    CGFloat newX = self.cursor.frame.origin.x + _pixelsPerSecond;
    [UIView animateWithDuration:.25 animations:^{
        self.cursor.frame = CGRectMake(newX, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
    }];

    //if the api has not told the timeline to advance to a new index...
    if (++_currentBlock.timeSpent > _currentBlock.timeAllowance) {
        
        //visually expand the currentBlock
        _currentBlock.frame = CGRectMake(_currentBlock.frame.origin.x, _currentBlock.frame.origin.y, _currentBlock.frame.size.width + _pixelsPerSecond, _currentBlock.frame.size.height);
        
        //visually compress the remaining blocks
#warning - incomplete method

        
    }
    
    if(--_speechTimeRemaining == 3) [_timer invalidate];
    
}

#pragma mark - TimeLine API


-(void)startTimer {
    
    _timeBlockIndex = 0;
    _currentBlock   = [[self.view subviews] firstObject];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(advanceCursor)
                                            userInfo:nil
                                             repeats:YES];
    
}

-(void)advanceToBlockAtIndex:(NSInteger)index {
    
    _currentBlock.isComplete = YES;
    
    if ([[[self.view subviews] objectAtIndex:index] isKindOfClass:[TimeBlock class]]) {
        
        //make the time block at the selected index the 'currentBlock'
        _currentBlock = [[self.view subviews] objectAtIndex:index];
        
        //animate cursor transition to new block
        CGFloat newX = _currentBlock.frame.origin.x;
        [UIView animateWithDuration:1 animations:^{
            self.cursor.frame = CGRectMake(newX, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
        } completion:^(BOOL finished) {
            
            //recalculate time for all blocks
            [self recalculateTimeForAllBlocks];
            
            //redraw timeline
            [self redrawTimeline];
            
            //animate cursur back to the new block
            [UIView animateWithDuration:1 animations:^{
                self.cursor.frame = CGRectMake(newX, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
            }];
            
        }];
        
    }
}

-(void)recalculateTimeForAllBlocks {
    CGFloat timeSpent           = 0;
    CGFloat targetTimeRemaing   = 0;
    for (TimeBlock *block in self.view.subviews) {
        if (block.isComplete) {
            timeSpent += block.timeSpent;
        } else {
            targetTimeRemaing += block.timeAllowance;
            
        }
    }
    
    CGFloat timeRemaining   = _speechRunTime - timeSpent;
    CGFloat timeDifference  =  timeRemaining - targetTimeRemaing;
    
    CGFloat actualTimeRemainig      = targetTimeRemaing + timeDifference;
    CGFloat blockPercentageOfTime;
    
    for (TimeBlock *block in self.view.subviews) {
        if (block.isComplete == NO) {
            blockPercentageOfTime   = block.timeAllowance / targetTimeRemaing;
            block.timeAllowance     = blockPercentageOfTime * actualTimeRemainig;
        }
    }
    
}







-(void)redrawTimeline {
    CGFloat movingX = 0;
    CGFloat width   = 0;
    
    for (TimeBlock *block in self.view.subviews) {
        
        //create new timeblock
        
        TimeBlock *newBlock = [[TimeBlock alloc] initWithFrame:CGRectMake(movingX, 10, width, TIMELINE_VIEW_HEIGHT - 20)];
        
        //time tracking properties
//        newBlock.timeAllowance  = card.runTime;
        newBlock.timeSpent      = 0;
        
        if ([[self.view.subviews lastObject] isKindOfClass:[TimeBlock class]]) {
            TimeBlock *preceedingBlock  = [self.view.subviews lastObject];
            preceedingBlock.nextBlock   = newBlock;
        }
        
        [self.view addSubview:newBlock];
        movingX += width;
        
        
    }
}







#pragma mark - helper methods

-(NSInteger)numberOfincompleteBlocks {
    NSInteger incompleteBlocks = 0;
    for (TimeBlock *block in self.view.subviews) {
        if (!block.isComplete) {
            incompleteBlocks++;
        }
    }
    
    return incompleteBlocks;
}

-(TimeBlock *)blockAtCursorPosition {
    for (TimeBlock *block in self.view.subviews) {
        if (_cursor.frame.origin.x >= block.frame.origin.x) {
            if (block.nextBlock) {
                if(_cursor.frame.origin.x < block.nextBlock.frame.origin.x) {
                    /* this line will execute if,
                     1.) the cursor is past the blocks startpoint,
                     2.) the block has a pointer to another block
                     3.) the cursor is not past the next blocks startpoint */
                    return block;
                }
            } else {
                //the cursor is past the block's startpoint, and there are no more blocks in the timeline
                return block;
            }
        }
    }
    return [TimeBlock new];
}

-(CGFloat)timeRemainingForBlockAtIndex:(NSInteger)index {
    if ([[[self.view subviews] objectAtIndex:index] isKindOfClass:[TimeBlock class]]) {
        TimeBlock *timeBlock = [[self.view subviews] objectAtIndex:index];
        return timeBlock.timeRemaining;
    }
    
    return 0;
}


@end
