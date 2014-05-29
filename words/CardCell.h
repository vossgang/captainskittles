//
//  CardCell.h
//  words
//
//  Created by Matthew Voss on 5/27/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardStyleKit.h"



@interface CardCell : UICollectionViewCell
@property (weak, nonatomic)  UITextView *titleLabel;
@property (weak, nonatomic)  UILabel *pointLabel;
@property (weak, nonatomic)  UILabel *timeLabel;



@end
