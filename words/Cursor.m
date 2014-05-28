//
//  Cursor.m
//  words
//
//  Created by Christopher Cohen on 5/28/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "Cursor.h"

@implementation Cursor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor        = [UIColor clearColor];
        self.clipsToBounds          = NO;
        self.layer.masksToBounds    = NO;
        self.alpha                  = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    
    //// Polygon Drawing
    UIBezierPath* polygonPath = UIBezierPath.bezierPath;
    [polygonPath moveToPoint: CGPointMake(7.85, 36)];
    [polygonPath addLineToPoint: CGPointMake(14, 41.7)];
    [polygonPath addLineToPoint: CGPointMake(10.25, 41.29)];
    [polygonPath addLineToPoint: CGPointMake(5.75, 41.29)];
    [polygonPath addLineToPoint: CGPointMake(2, 41.7)];
    [polygonPath addLineToPoint: CGPointMake(7.85, 36)];
    [polygonPath closePath];
    [UIColor.grayColor setFill];
    [polygonPath fill];
    
    
    //// Polygon 2 Drawing
    UIBezierPath* polygon2Path = UIBezierPath.bezierPath;
    [polygon2Path moveToPoint: CGPointMake(7.85, 25)];
    [polygon2Path addLineToPoint: CGPointMake(14, 19.3)];
    [polygon2Path addLineToPoint: CGPointMake(10.25, 19.71)];
    [polygon2Path addLineToPoint: CGPointMake(5.75, 19.71)];
    [polygon2Path addLineToPoint: CGPointMake(2, 19.3)];
    [polygon2Path addLineToPoint: CGPointMake(7.85, 25)];
    [polygon2Path closePath];
    [UIColor.grayColor setFill];
    [polygon2Path fill];

}


@end
