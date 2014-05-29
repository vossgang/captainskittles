//
//  SpeechController.m
//  words
//
//  Created by seanmcneil on 5/29/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SpeechController.h"

@interface SpeechController ()
{
    double _runTime;
}

@end

@implementation SpeechController

- (void)calculateTotalTime:(Speech *)speech {
    _runTime = 0;
    for (Card *card in speech.cards) {
        _runTime += card.runTime;
    }
}

-(NSTimeInterval)runTime
{
    NSTimeInterval time = 0;
    for (Card *card in self.cards) {
        time += card.runTime;
    }
    return time;
}

@end
