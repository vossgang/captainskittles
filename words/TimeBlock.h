//
//  TimeBlock.h
//  words
//
//  Created by Christopher Cohen on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface TimeBlock : UIView

@property (nonatomic, weak) TimeBlock *nextBlock;
@property (nonatomic, readwrite) CGFloat timeRemaining, timeSpent, timeAllowance;
@property (nonatomic, readwrite) BOOL isComplete;

@end
