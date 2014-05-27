//
//  Speech.m
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "Speech.h"
#import "Card.h"

@interface Speech () <NSCopying, UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation Speech

+(id)newSpeech {
    Speech *speech = [Speech new];
    if (speech) {
        speech.cards = [NSMutableArray new];
        [speech.cards addObject:[Card newTitleCardForSpeech:speech]];
        [speech.cards addObject:[Card newPrefaceCardForSpeech:speech]];
        [speech.cards addObject:[Card newBodyCardForSpeech:speech]];
        [speech.cards addObject:[Card newConclusionCardForSpeech:speech]];
    }
    return speech;
}

+ (id)loadSpeechWith:(DSSpeech *)withSpeech {
    
    
    return [Speech new];
}

-(void)calculateTime {
    [self calculateTotalTime:self];
}

-(void)calculateTotalTime:(Speech *)speech {
    speech.runTime = 0;
    for (Card *card in speech.cards) {
        speech.runTime += card.runTime;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    Speech *copy = [[[self class] allocWithZone:zone] init];
    [copy setCards:self.cards];
    [copy setKeyWords:self.keyWords];
    [copy setRunTime:self.runTime];
    [copy setTimeRemaning:self.timeRemaning];
    
    return copy;
}

-(NSTimeInterval)runTime
{
    NSTimeInterval time = 0;
    for (Card *card in self.cards) {
        time += card.runTime;
    }
    
    return time;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExplosionCell" forIndexPath:indexPath];
    
    return cell;
}

@end
