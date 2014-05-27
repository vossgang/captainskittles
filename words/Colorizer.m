//
//  Colorizer.m
//  words
//
//  Created by Brian Radebaugh on 5/27/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "Colorizer.h"

@implementation Colorizer

+ (UIColor *)colorFromTimeRemaining:(NSTimeInterval)remainingTime withTotalTime:(NSTimeInterval)totalTime usingColors:(NSArray *)colors
{
    // Handle Insufficient Colors || Incorrect remainingTime
    if (colors.count < 2 || remainingTime >= totalTime) return [colors firstObject];
    
    double percentOfTimePast = (totalTime - remainingTime) / totalTime;
    NSInteger toColorIndex = ceil(percentOfTimePast);
    
    // If toColorIndex Is Past the Number of Colors Sent then Return Final Color
    if (toColorIndex > colors.count - 1) return [colors lastObject];
    
    NSInteger fromColorIndex = toColorIndex - 1;
    UIColor *fromColor = colors[fromColorIndex];
    UIColor *toColor = colors[toColorIndex];
    
    // Return nil If Either fromColor || toColor Are Not UIColor's
    if (![fromColor isKindOfClass:[UIColor class]] || ![toColor isKindOfClass:[UIColor class]]) return nil;
    
    // Get Components of fromColor and toColor
    const CGFloat *fromComponents = CGColorGetComponents(fromColor.CGColor);
    NSArray *fromColorComponents = @[@(fromComponents[0]), @(fromComponents[1]), @(fromComponents[2]), @(fromComponents[3])];
    const CGFloat *toComponents = CGColorGetComponents(toColor.CGColor);
    NSArray *toColorComponents = @[@(toComponents[0]), @(toComponents[1]), @(toComponents[2]), @(toComponents[3])];
    
    // Create currentColor Based on Percentage Completed
    NSMutableArray *currentColorComponents = [@[@0.0, @0.0, @0.0, @0.0] mutableCopy];
    double colorPercentage = (percentOfTimePast - floor(percentOfTimePast));
    if (percentOfTimePast == floor(percentOfTimePast)) colorPercentage = 1; // if 0% then should be 100%
    
    for (NSInteger i = 0; i <=3 ; i++) {
        // Short Form of Equation = (to - from) * % + from
        currentColorComponents[i] = @(([toColorComponents[i] doubleValue] - [fromColorComponents[i] doubleValue]) * colorPercentage + [fromColorComponents[i] doubleValue]);
    }
    
    return [UIColor colorWithRed:[currentColorComponents[0] doubleValue]
                           green:[currentColorComponents[1] doubleValue]
                            blue:[currentColorComponents[2] doubleValue]
                           alpha:[currentColorComponents[3] doubleValue]];
}

@end
