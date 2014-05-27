//
//  CardCell.h
//  words
//
//  Created by Matthew Voss on 5/27/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CardCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITextView *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;



@end
