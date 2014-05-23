//
//  Card.m
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "Card.h"

@implementation Card

+(id)newTitleCardForSpeech:(Speech *)speech {
    Card *card = [Card new];
    if (card) {
        card.userEdited = NO;
        card.speech     = speech;
        card.title      = @"Speech Title";
        card.runTime    = 30;
        card.type       = titleCard;
        [card.speech calculateTime];
    }
    return card;
    
}

+(id)newPrefaceCardForSpeech:(Speech *)speech {
    Card *card = [Card new];
    if (card) {
        card.userEdited = NO;
        card.speech     = speech;
        card.title      = @"Preface";
        card.runTime    = 60;
        card.preface    = @"A description of the scope of your speech goes here";
        card.type       = prefaceCard;
        [card.speech calculateTime];
    }
    return card;
}

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
        [card.speech calculateTime];

    }
    return card;
}


@end
