//
//  PresentationCardView.m
//  words
//
//  Created by Christopher Cohen on 5/28/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "PresentationCardView.h"
#import "CardStyleKit.h"

@implementation PresentationCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setCard:(Card *)card {
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [CardStyleKit drawPresentationCardWithTitle:@"" withTextField:@"" withCardNumber:@"" andTimeRemaining:@""];
}


@end
