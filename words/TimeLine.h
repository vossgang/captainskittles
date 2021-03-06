//
//  TimeLine.h
//  words
//
//  Created by Christopher Cohen on 5/25/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Speech.h"

@interface TimeLine : NSObject

@property (nonatomic, strong) UIView *view;

+(TimeLine *)newTimeLineFromSpeech:(Speech *)speech isSubviewOf:(UIView *)view withFrame:(CGRect)frame;

-(BOOL)isInitialized;

-(void)start;
-(void)stop;

-(void)advanceToNextBlock;

@end
