//
//  SpeechController.m
//  words
//
//  Created by seanmcneil on 5/29/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SpeechController.h"

@interface SpeechController ()


@end

@implementation SpeechController

+ (NSTimeInterval)calculateTotalTime:(Speech *)speech {
    double _runTime = 0;
    for (Card *card in speech.cards) {
        if (card.userEdited) {
            _runTime += [card.runTime doubleValue];
        }
    }
    
    return _runTime;
}

@end
