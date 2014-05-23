//
//  Speech.h
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Speech : NSObject

@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSString *keyWords; //if we have time, store similar words

//Timeline Management
@property (nonatomic) NSTimeInterval runTime, timeRemaning;


//class methods
+(id)newSpeech;

//instance methods
-(void)calculateTime;



@end
