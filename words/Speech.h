//
//  Speech.h
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSSpeech.h"

@interface Speech : NSObject

@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) DSSpeech *speechData;

//Timeline Management
@property (nonatomic) NSTimeInterval runTime, timeRemaning;


//class methods
+(id)newSpeech;
+ (id)loadSpeechWith:(DSSpeech *)withSpeech;

//instance methods
-(void)calculateTime;

@end
