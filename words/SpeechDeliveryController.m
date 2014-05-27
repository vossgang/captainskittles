//
//  SpeechDeliveryController.m
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SpeechDeliveryController.h"

@implementation SpeechDeliveryController

+(instancetype)newDeliveryControllerForSpeech:(Speech *)speech {
    SpeechDeliveryController *controller = [SpeechDeliveryController new];
    
    if (controller) {
        controller.speech = speech;
    }
    
    return controller;
}


-(void)start
{
    
}

-(void)stop
{
    
}

@end
