//
//  SpeechDeliveryController.h
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Speech.h"

@interface SpeechDeliveryController : NSObject

//@property (nonatomic, copy) Speech *speech;
@property (nonatomic, weak) Speech *speech;

@property (nonatomic) NSTimeInterval totalTime, elapsedTime, remaningTime;

+(instancetype)newDeliveryControllerForSpeech:(Speech *)speech;

-(void)start;
-(void)stop;

@end
