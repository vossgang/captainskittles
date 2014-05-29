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
        if (card.userEdited) {
            _runTime += [card.runTime doubleValue];
        }
    }
}

-(NSTimeInterval)runTime
{
    NSTimeInterval time = 0;
    for (Card *card in [[DataController dataStore] allCardItems]) {
        if (card.userEdited) {
            _runTime += [card.runTime doubleValue];
        }    }
    return time;
}

@end
