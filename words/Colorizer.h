//
//  Colorizer.h
//  words
//
//  Created by Brian Radebaugh on 5/27/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Colorizer : NSObject

+ (UIColor *)colorFromTimeRemaining:(NSTimeInterval)remainingTime withTotalTime:(NSTimeInterval)totalTime usingColors:(NSArray *)colors;

+(UIColor *)gradeColor:(UIColor *)color forTimeRemaining:(NSTimeInterval)timeRemaining;


@end
