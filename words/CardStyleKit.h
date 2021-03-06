//
//  StyleKitName.h
//  ProjectName
//
//  Created by AuthorName on 5/28/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>


@interface CardStyleKit : NSObject

// Drawing Methods

+ (void)drawExplosionViewCardWithTitle:(NSString *)title withPointCount:(NSString *)points timeRemaining:(NSString *)timeRemaining withinFrame:(CGRect)frame;

+ (void)drawPresentationCardWithTitle:(NSString *)title withTextField:(NSString *)textField withCardNumber:(NSString *)cardNumber andTimeRemaining:(NSString *)timeRemaining;

+ (void)drawStackOfCardsWithTitle:(NSString *)title withPointCount:(NSString *)points andDuration:(NSString *)duration;

@end
