//
//  PresentationCardView.h
//  words
//
//  Created by Christopher Cohen on 5/28/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "Constant.h"

@interface PresentationCardView : UIView

@property (nonatomic, weak) Card *card;
@property (nonatomic) PresentationCardState state;

-(void)setCard:(Card *)card;

@end
