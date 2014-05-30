//
//  RIVCustomAlertViewController.h
//  delete when done
//
//  Created by Brian Radebaugh on 5/29/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RIVCustomAlertViewControllerDelegate <NSObject>

@optional
- (void)customAlertViewConrtollerDidRemoveFromParentControllerWithName:(NSString *)name;

@end

@interface RIVCustomAlertViewController : UIViewController

@property (unsafe_unretained, nonatomic) id<RIVCustomAlertViewControllerDelegate> delegate;
@property (readonly, nonatomic) NSString *name;

- (instancetype)initWithName:(NSString *)name frame:(CGRect)frame alertMessage:(NSString *)message andMinimumDuration:(NSInteger)duration;

@end