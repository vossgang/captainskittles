//
//  SpeechCell.h
//  words
//
//  Created by Matthew Voss on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeechCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UITextView *speechCellTitle;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCardsLabel;

@end
