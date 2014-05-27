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
#import "TimeLine.h"

@interface SpeechViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;

@property (weak, nonatomic) IBOutlet UITextField *cardTitle;
@property (weak, nonatomic) IBOutlet UITextField *cardPointOne;
@property (weak, nonatomic) IBOutlet UITextField *cardPointTwo;
@property (weak, nonatomic) IBOutlet UITextField *cardPointThree;

@property (nonatomic, strong) SpeechDeliveryController *speechDeliverController;
@property (nonatomic) CGRect textFieldFrame;

@property (nonatomic, readwrite) BOOL   speechIsRunning;

//Timeline Properties
@property (strong, nonatomic) TimeLine *timeLine;

@end

@implementation SpeechViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _speechIsRunning = NO;
    _speechDeliverController = [SpeechDeliveryController newDeliveryControllerForSpeech:self.currentSpeech];
    
    _cardPointOne.delegate                  = self;
    _cardPointTwo.delegate                  = self;
    _cardPointThree.delegate                = self;
    
    _cardTitle.delegate                     = self;
    
    _cardCollectionView.dataSource          = self;
    _cardCollectionView.delegate            = self;
    _cardCollectionView.backgroundColor     = [UIColor whiteColor];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self collectionView:_cardCollectionView didSelectItemAtIndexPath:indexPath];
    
    [self instantiateNewTimeLine];
    
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (![textField isEqual:_cardPointOne]) {
        [_cardPointOne setHidden:YES];
    }
    
    if (![textField isEqual:_cardPointTwo]) {
        [_cardPointTwo setHidden:YES];
    }
    
    if (![textField isEqual:_cardPointThree]) {
        [_cardPointThree setHidden:YES];
    }
    
    if (![textField isEqual:_cardTitle]) {
        [_cardTitle setHidden:YES];
    }
    _textFieldFrame = textField.frame;
    
    [UIView animateWithDuration:.33 animations:^{
        textField.center = CGPointMake(textField.center.x, 22);
    } completion:^(BOOL finished) {

    }];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_cardTitle setHidden:NO];
    [_cardPointOne setHidden:NO];
    [_cardPointTwo setHidden:NO];
    [_cardPointThree setHidden:NO];
    
    textField.frame = _textFieldFrame;
    
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.currentSpeech.cards.count;
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Card *detailCard = _currentSpeech.cards[indexPath.row];
    
    _cardTitle.text         = detailCard.title;
    _cardPointOne.text      = detailCard.points[0];
    _cardPointTwo.text      = detailCard.points[1];
    _cardPointThree.text    = detailCard.points[2];
}


#pragma mark - TimeLine Management

- (void)instantiateNewTimeLine
{
    //setup timeline
    [_timeLine.view removeFromSuperview];
    
    _timeLine = NULL;
    
    if (_speechIsRunning) {
        _timeLine = [TimeLine newTimeLineFromSpeech:_speechDeliverController.speech isSubviewOf:self.view withFrame:CGRectMake(128, 0, 420, 60)];
    } else {
        _timeLine = [TimeLine newTimeLineFromSpeech:_currentSpeech isSubviewOf:self.view withFrame:CGRectMake(128, 0, 420, 60)];
    }

}


-(void)animateTimeLineRefactor {
    CGRect originalTimeLineFrame = _timeLine.view.frame;
    
    [UIView animateWithDuration:.25 animations:^{
        _timeLine.view.alpha = 0;

        _timeLine.view.transform = CGAffineTransformMakeScale(.5, .5);
        
    } completion:^(BOOL finished) {
        
        [self instantiateNewTimeLine];
    
        [UIView animateWithDuration:.25 animations:^{
            _timeLine.view.alpha = 1;
            _timeLine.view.transform = CGAffineTransformMakeScale(1, 1);

        }];
    }];
}


#pragma mark - IBActions

- (IBAction)newCard:(id)sender
{
    NSIndexPath *index = [[_cardCollectionView indexPathsForSelectedItems] firstObject];
    [self.currentSpeech.cards insertObject:[Card newBodyCardForSpeech:self.currentSpeech] atIndex:(index.row + 1)];
    [_cardCollectionView reloadData];
    
    //refactor the timeline for the new cards
    [self animateTimeLineRefactor];
}

- (IBAction)backToMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (IBAction)Stop:(id)sender
{
    [self playPause:sender];
}

- (IBAction)playPause:(id)sender
{
    if (_speechIsRunning) {
        [_speechDeliverController stop];
        _speechIsRunning = NO;
    } else {
        [_speechDeliverController start];
        _speechIsRunning = YES;
    }
}


@end
