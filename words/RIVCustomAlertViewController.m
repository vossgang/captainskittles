//
//  RIVCustomAlertViewController.m
//  delete when done
//
//  Created by Brian Radebaugh on 5/29/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "RIVCustomAlertViewController.h"

@interface RIVCustomAlertViewController ()

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation RIVCustomAlertViewController

- (instancetype)initWithName:(NSString *)name frame:(CGRect)frame alertMessage:(NSString *)message andMinimumDuration:(NSInteger)duration
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Setup View
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor whiteColor];
        self.view.layer.masksToBounds = YES;
        self.view.layer.cornerRadius = 15.0;
        self.name = (name) ? name : message;
        
        // Setup UITextField
        self.message = message;
        [self setupUITextView];
        
        // Setup UITapGestureRecognizer after Delay
        [self performSelector:@selector(addTapToDismiss) withObject:nil afterDelay:duration];
    }
    return self;
}

- (void)setupUITextView
{
    // Setup self.textView with Horizontally and Vertically Centered Text
    CGRect textViewFrame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.textView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.textView.text = self.message;
    CGSize fittingSize = [self.textView sizeThatFits:self.textView.frame.size];
    float verticalInset = (self.view.frame.size.height - fittingSize.height) / 2.0;
    self.textView.contentInset = UIEdgeInsetsMake(verticalInset, 0, 0, 0);
    self.textView.textAlignment = NSTextAlignmentCenter;
    
    // Set UITextView Properties and Add to View
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.textView];
}

- (void)addTapToDismiss
{
    self.view.backgroundColor = [UIColor yellowColor];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewController)];
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)dismissViewController
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    [self.delegate customAlertViewConrtollerDidRemoveFromParentControllerWithName:self.name];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
