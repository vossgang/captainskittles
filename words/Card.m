//
//  Card.m
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "Card.h"
#import "DataController.h"

@implementation Card


+(id)newBodyCardForSpeech:(Speech *)speech {
    Card *card = [Card new];
    if (card) {
        card.userEdited = NO;
        card.title      = @"Point";
        card.runTime    = 120;
        card.speech     = speech;

        //populate points string with placeHolder text
        [card.points addObject:@"My main subpoint"];
        [card.points addObject:@"My second subpoint"];
        [card.points addObject:@"My third subpoint"];
        
        card.type    = bodyCard;
        card.points     = [@[[NSString new], [NSString new], [NSString new], [NSString new], [NSString new]] mutableCopy];
        [card.speech calculateTime];

    }
    return card;
}

+(id)newConclusionCardForSpeech:(Speech *)speech {
    Card *card = [Card new];
    if (card) {
        card.userEdited = NO;
        card.speech     = speech;
        card.title      = @"Conclusion";
        card.runTime    = 30;
        card.conclusion = @"A conclusion statement for your speech goes here";
        card.type       = conclusionCard;
        card.points     = [@[[NSString new], [NSString new], [NSString new], [NSString new], [NSString new]] mutableCopy];
        [card.speech calculateTime];

    }
    return card;
}


@end
