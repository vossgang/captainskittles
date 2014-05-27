//
//  SpeechViewController.m
//  words
//
//  Created by Matthew Voss on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SpeechViewController.h"
#import "Card.h"
#import "SpeechDeliveryController.h"

@interface SpeechViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;

@property (nonatomic, weak) Card *currentCard;

@property (weak, nonatomic) IBOutlet UITextField *cardTitle;
@property (weak, nonatomic) IBOutlet UITextField *cardPointOne;
@property (weak, nonatomic) IBOutlet UITextField *cardPointTwo;
@property (weak, nonatomic) IBOutlet UITextField *cardPointThree;

@property (nonatomic, strong) SpeechDeliveryController *speechDC;
@property (nonatomic) CGRect textFieldFrame;

@property (nonatomic, readwrite) BOOL   speechIsRunning;

@end

@implementation SpeechViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _speechIsRunning = NO;
    _speechDC = [SpeechDeliveryController newDeliveryControllerForSpeech:self.detailSpeech];
    
    _cardPointOne.delegate                  = self;
    _cardPointTwo.delegate                  = self;
    _cardPointThree.delegate                = self;
    _cardTitle.delegate                     = self;
    
    _cardCollectionView.dataSource          = self;
    _cardCollectionView.delegate            = self;
    _cardCollectionView.backgroundColor     = [UIColor whiteColor];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self collectionView:_cardCollectionView didSelectItemAtIndexPath:indexPath];
    // Do any additional setup after loading the view.
}

- (IBAction)newCard:(id)sender
{
    NSIndexPath *index = [[_cardCollectionView indexPathsForSelectedItems] firstObject];
    [self.detailSpeech.cards insertObject:[Card newBodyCardForSpeech:self.detailSpeech] atIndex:(index.row + 1)];
    [self collectionView:_cardCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index.row + 1 inSection:0]];
    [_cardCollectionView reloadData];
}

- (IBAction)backToMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_cardTitle setHidden:YES];
    [_cardPointOne setHidden:YES];
    [_cardPointTwo setHidden:YES];
    [_cardPointThree setHidden:YES];
    
    [textField setHidden:NO];

    _textFieldFrame = textField.frame;
    
    [UIView animateWithDuration:.33 animations:^{
        textField.center = CGPointMake(textField.center.x, 22);
    } completion:^(BOOL finished) {

    }];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    [_cardTitle setHidden:NO];
    [_cardPointOne setHidden:NO];
    [_cardPointTwo setHidden:NO];
    [_cardPointThree setHidden:NO];
    
    _currentCard.points[0] = _cardPointOne.text;
    _currentCard.points[1] = _cardPointTwo.text;
    _currentCard.points[2] = _cardPointThree.text;
    _currentCard.title     = _cardTitle.text;
    
    textField.frame = _textFieldFrame;
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.detailSpeech.cards.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor orangeColor];
    
    return cell;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)Stop:(id)sender
{
    [self playPause:sender];
}

- (IBAction)playPause:(id)sender
{
    if (_speechIsRunning) {
        [_speechDC stop];
        _speechIsRunning = NO;
    } else {
        [_speechDC start];
        _speechIsRunning = YES;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Card *detailCard        = _detailSpeech.cards[indexPath.row];
    
    _cardTitle.text         = detailCard.title;
    _cardPointOne.text      = detailCard.points[0];
    _cardPointTwo.text      = detailCard.points[1];
    _cardPointThree.text    = detailCard.points[2];
    _currentCard            = detailCard;
}



@end
