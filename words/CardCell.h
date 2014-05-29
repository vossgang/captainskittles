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
@property (weak, nonatomic)  NSString *titleLabel;
@property (weak, nonatomic)  NSString *pointLabel;
@property (weak, nonatomic)  NSString *timeLabel;



@end
