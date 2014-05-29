//
//  TimeBlock.h
//  words
//
//  Created by Christopher Cohen on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "Constants.h"

@interface TimeBlock : UIView

@property (nonatomic, weak) TimeBlock *nextBlock;
@property (nonatomic, readwrite) CGFloat duration, timeRemaining;
@property (nonatomic) CGFloat percentageOfTimeLine;
@property (nonatomic) BlockState state;
@property (nonatomic) UIColor *color;

+(TimeBlock *)newTimeBlockFromCard:(Card *)card andSpeechRunTime:(NSTimeInterval)speechRunTime;

@end
