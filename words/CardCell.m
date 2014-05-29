//
//  CardCell.m
//  words
//
//  Created by Matthew Voss on 5/27/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "CardCell.h"
#import "CardStyleKit.h"

@implementation CardCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [CardStyleKit drawExplosionViewCardWithTitle:@"" withPointCount:@"" timeRemaining:@"" withinFrame:rect];
}


@end
