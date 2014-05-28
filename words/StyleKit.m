//
//  MyStyleKit.m
//  ProjectName
//
//  Created by AuthorName on 5/27/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "StyleKit.h"


@implementation StyleKit

#pragma mark Cache

static UIColor* _color = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];

}

#pragma mark Colors

+ (UIColor*)color { return _color; }

#pragma mark Drawing Methods

+ (void)drawTimeBlockWithFrame: (CGRect)frame andColor:(UIColor *)color
{
    //// Color Declarations
    UIColor* backgroundColor = color;
    UIColor* color3 = [UIColor clearColor];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + 1.5, CGRectGetMinY(frame) + 25.5, CGRectGetWidth(frame) - 3.5, 9.5) cornerRadius: 2];
    [backgroundColor setFill];
    [rectanglePath fill];
    [color3 setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];


}

@end