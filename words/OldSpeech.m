//
//  OldSpeech.m
//  words
//
//  Created by seanmcneil on 5/29/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "OldSpeech.h"
#import "Card.h"

@implementation OldSpeech

// Needed
-(void)calculateTotalTime:(Speech *)speech {
    speech.runTime = 0;
    for (Card *card in speech.cards) {
        speech.runTime += card.runTime;
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
