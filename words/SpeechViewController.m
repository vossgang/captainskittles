//
//  SpeechViewController.m
//  words
//
//  Created by Matthew Voss on 5/26/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "SpeechViewController.h"
#import "DataController.h"
#import "SpeechDeliveryController.h"
#import "TimeLine.h"
#import "CardCell.h"
#import "Constant.h"
#import "PresentationCardView.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SpeechController.h"

@interface SpeechViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UITextViewDelegate, LXReorderableCollectionViewDelegateFlowLayout, LXReorderableCollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *cardEditor;

@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;

@property (nonatomic, weak) Card *currentCard;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *addCardButton;

@property (weak, nonatomic) IBOutlet UITextField *cardTitle;
@property (weak, nonatomic) IBOutlet UITextField *point1;
@property (weak, nonatomic) IBOutlet UITextField *point2;
@property (weak, nonatomic) IBOutlet UITextField *point3;
@property (weak, nonatomic) IBOutlet UITextField *point4;
@property (weak, nonatomic) IBOutlet UITextField *point5;

@property (nonatomic, strong) SpeechDeliveryController *speechDeliverController;
@property (nonatomic) CGRect textFieldFrame;
@property (nonatomic, strong) NSString *oldTextFieldText;
@property (nonatomic) CGRect textViewFrame;
@property (nonatomic, strong) NSString *oldTextViewText;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;

@property (weak, nonatomic) IBOutlet UITextView *textView;

//UI element properties
@property (strong, nonatomic) PresentationCardView *presentationCard;

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
    
    _point1.delegate                        = self;
    _point2.delegate                        = self;
    _point3.delegate                        = self;
    _point4.delegate                        = self;
    _point5.delegate                        = self;
    _cardTitle.delegate                     = self;
    _textView.delegate                      = self;
    _cardCollectionView.dataSource          = self;
    _cardCollectionView.delegate            = self;
    _cardCollectionView.backgroundColor     = [UIColor clearColor];
    _oldTextViewText                        = @"";
    
    [_point1 setTag:1];
    [_point2 setTag:2];
    [_point3 setTag:3];
    [_point4 setTag:4];
    [_point5 setTag:5];
    
    //setup card editor
    _cardEditor.backgroundColor = [UIColor clearColor];
    
    //presentation card view
    _presentationCard = [[PresentationCardView alloc] initWithFrame:CGRectMake(128, 55, 420, 240)];
    [self.view insertSubview:_presentationCard belowSubview:_cardEditor];
    
    [_textView setHidden:YES];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self collectionView:_cardCollectionView didSelectItemAtIndexPath: indexPath];
    
    [self instantiateNewTimeLine];
    
}

- (IBAction)incramentTime:(id)sender
{
    UIStepper *step = sender;
    NSTimeInterval time = step.value * 15;
    _currentCard.runTime = [NSNumber numberWithDouble:time];
    
    //if the current card has a run time it is edited, else it is not edited
    _currentCard.userEdited = _currentCard.runTime;
    
    int minutes = [_currentCard.runTime doubleValue] / 60;
    int seconds = (int)[_currentCard.runTime doubleValue] % 60;
    if (seconds != 0) {
        _timeLabel.text     = [NSString stringWithFormat:@"%d minutes %d seconds", minutes, seconds];
    } else {
        _timeLabel.text     = [NSString stringWithFormat:@"%d minutes", minutes];
    }
    
    [_cardCollectionView reloadData];
    [self animateTimeLineRefactor];
    
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _oldTextFieldText = textField.text;
    
    [_cardTitle setHidden:YES];
    [_point1 setHidden:YES];
    [_point2 setHidden:YES];
    [_point3 setHidden:YES];
    [_point4 setHidden:YES];
    [_point5 setHidden:YES];
    
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
    [_point1 setHidden:NO];
    [_point2 setHidden:NO];
    [_point3 setHidden:NO];
    [_point4 setHidden:NO];
    [_point5 setHidden:NO];
    
    if (![_oldTextFieldText isEqual:textField.text]) {
        [_currentCard setUserEdited:[NSNumber numberWithInt:1]];
        [self animateTimeLineRefactor];
    }
    // Iterate through all the points associated with the card and then pull the textfield
    // by its tag that is associated with the points sequence number
    for (BodyPoint *point in _currentCard.points) {
        UITextField *currentField = (UITextField *)[self.view viewWithTag:[point.sequence intValue] + 1];
        [point setWords:currentField.text];
    }
    _currentCard.title     = _cardTitle.text;
    
    textField.frame = _textFieldFrame;
    [self showActiveTextFields];
    
    [_cardCollectionView reloadData];
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _textViewFrame = textView.frame;
    _oldTextViewText = textView.text;
    
    [UIView animateWithDuration:.33 animations:^{
        textView.frame = CGRectMake(textView.frame.origin.x, 0, textView.frame.size.width, textView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    [_cardTitle setHidden:YES];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (![_oldTextViewText isEqual:textView.text]) {
        [_currentCard setUserEdited:[NSNumber numberWithBool:YES]];
        [self animateTimeLineRefactor];
    }
    
    switch ([_currentCard.type intValue]) {
        case conclusionCard:    _currentCard.conclusion = _textView.text; break;
        case prefaceCard:       _currentCard.preface    = _textView.text; break;
        default: break;
    }
    
    _textView.frame = _textViewFrame;
    [_cardTitle setHidden:NO];
    _currentCard.preface   = _textView.text;
    
    [textView resignFirstResponder];
    
    
    return YES;
}

//- (void)textViewDidEndEditing:(UITextView *)textView {
//    if ([textView.text isEqualToString:@""]) {
//        [textView setText:@"Notes"];
//    }
//    [textView resignFirstResponder];
//}
//
//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    if ([textView.text isEqual:@"Notes"]) {
//        [textView setText:@""];
//    }
//}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_textView isFirstResponder]) {
        [self textViewShouldEndEditing:_textView];
    }
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
    CardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    
    // Obtain the specified card by searching the cards set for one with the provided sequence number
    Card *card = [[[DataController dataStore] allCardItems:_currentSpeech] objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.titleLabel.text    = card.title;
    int min = [card.runTime doubleValue] / 60;
    int sec = (int)[card.runTime doubleValue] % 60;
    NSString *partialMin = @"";
    switch (sec) {
        case 15: partialMin = ONE_FORTH; break;
        case 30: partialMin = ONE_HALF; break;
        case 45: partialMin = THREE_FORTH; break;
        default:
            break;
    }
    if (min) {
        cell.timeLabel.text = [NSString stringWithFormat:@"%d%@ min", min, partialMin];
    } else {
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ min", partialMin];
    }
    int stringCounter = 0;
    for (BodyPoint *points in card.points) {
        if (points.words.length != 0) {
            stringCounter++;
        }
    }
    
    cell.titleLabel.text = card.title;
    cell.pointLabel.text = [NSString stringWithFormat:@"%d points", stringCounter];
    
    
    return cell;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_textView isFirstResponder] && (!_speechIsRunning)) {
        [self textViewShouldEndEditing:_textView];
    }
    
    _currentCard = [[[DataController dataStore] allCardItems:_currentSpeech] objectAtIndex:indexPath.row];
    _timeStepper.value      = [_currentCard.runTime intValue] / 15;
    
    _cardNumberLabel.text   = [NSString stringWithFormat:@"Card %d", (int)(indexPath.row + 1)];
    
    _cardTitle.text         = _currentCard.title;
    
    for (BodyPoint *point in _currentCard.points) {
        UITextField *currentField = (UITextField *)[self.view viewWithTag:([point.sequence intValue] + 1)];
        [currentField setText:point.words];
    }
    _textView.text          = @"";
    
    
    int minutes = [_currentCard.runTime doubleValue] / 60;
    int seconds = (int)[_currentCard.runTime doubleValue] % 60;
    if (seconds != 0) {
        _timeLabel.text     = [NSString stringWithFormat:@"%d minutes %d seconds", minutes, seconds];
    } else {
        _timeLabel.text     = [NSString stringWithFormat:@"%d minutes", minutes];
    }
    
    switch ([_currentCard.type intValue]) {
        case titleCard:
            [_textView setHidden:NO];
            break;
        case conclusionCard:
            [_textView setHidden:NO];
            _textView.text = _currentCard.conclusion;
            break;
        case prefaceCard:
            [_textView setHidden:NO];
            _textView.text = _currentCard.preface;
            break;
        default: [_textView setHidden:YES]; break;
    }
    
    if (_currentCard.type == titleCard) {
        NSString *string = _currentCard.title;
        string = [NSString stringWithFormat:@"%@\n%d cards", string, (int)_currentSpeech.cards.count];
        
        NSTimeInterval timeInterval = [SpeechController calculateTotalTime:_currentSpeech];
        int min = timeInterval / 60;
        int sec = (int)timeInterval % 60;
        if (sec) {
            string = [NSString stringWithFormat:@"%@\n%d minutes and %d seconds", string, min, sec];
        } else {
            string = [NSString stringWithFormat:@"%@\n%d minutes", string, min];
        }
        _textView.text = string;
        
        //hide all textfields
        [self hideTextFields];
        _textView.backgroundColor = [UIColor clearColor];
    } else {
        //unhide all textfields
        if (!_speechIsRunning) {
            [self unhideTextFields];
            _textView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (_speechIsRunning) {
        [_timeLine advanceToNextBlock];
        [_textView setHidden:NO];
        //do running stuff
        NSString *editedString = @"";
        NSString *newPointChar = @"*";
        //put all the points into the text view
        for (BodyPoint *point in _currentCard.points) {
            if (point.words.length > 0) {
                editedString = [NSString stringWithFormat:@"\n%@%@", newPointChar, point.words];
                _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text, editedString];
            }
            UITextField *currentField = (UITextField *)[self.view viewWithTag:([point.sequence intValue] + 1)];
            [currentField setText:point.words];
        }
    } else {
        [self showActiveTextFields];
        //do editing stuff
        //show the corresponding views
    }
}

-(void)hideTextFields
{
    [_point1 setHidden:YES];
    [_point2 setHidden:YES];
    [_point3 setHidden:YES];
    [_point4 setHidden:YES];
    [_point5 setHidden:YES];
}

-(void)unhideTextFields
{
    [_point1 setHidden:NO];
    [_point2 setHidden:NO];
    [_point3 setHidden:NO];
    [_point4 setHidden:NO];
    [_point5 setHidden:NO];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
#warning Will need to modify this to update sequence values on cards card.sequence
    // Card *card = self.currentSpeech.cards[fromIndexPath.row];
    //[self.currentSpeech.cards removeObjectAtIndex:fromIndexPath.row];
    //[self.currentSpeech.cards insertObject:card atIndex:toIndexPath.row];
}

-(int)numberOfPointsInCurrentCard
{
    int activePoints = 0;
    for (BodyPoint *point in _currentCard.points) {
        if (point.words.length > 0) {
            activePoints++;
            
        }
    }
    return activePoints;
}

-(void)showActiveTextFields
{
    if ([_currentCard.type intValue] == bodyCard) {
        switch ([self numberOfPointsInCurrentCard]) {
            case 0: [_point2 setHidden:YES];
                [_point3 setHidden:YES];
                [_point4 setHidden:YES];
                [_point5 setHidden:YES];
                break;
            case 1: [_point3 setHidden:YES];
                [_point4 setHidden:YES];
                [_point5 setHidden:YES];
                break;
            case 2: [_point4 setHidden:YES];
                [_point5 setHidden:YES];
                break;
            case 3: [_point5 setHidden:YES];
                break;
            default:
                break;
        }
    }
}


#pragma mark - TimeLine Management

- (void)instantiateNewTimeLine
{
    //setup timeline
    
    if ([SpeechController calculateTotalTime:_currentSpeech] > 0) {
        
        [_timeLine.view removeFromSuperview];
        
        _timeLine = NULL;
        
        if (_speechIsRunning) {
            _timeLine = [TimeLine newTimeLineFromSpeech:_speechDeliverController.speech isSubviewOf:self.view withFrame:CGRectMake(128, 0, 420, 60)];
        } else {
            _timeLine = [TimeLine newTimeLineFromSpeech:_currentSpeech isSubviewOf:self.view withFrame:CGRectMake(128, 0, 420, 60)];
        }
    }
}


-(void)animateTimeLineRefactor
{
//    CGRect  originalTimeLineFrame = _timeLine.view.frame;
    
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
    //[self.currentSpeech.cards insertObject:[Card newBodyCardForSpeech:self.currentSpeech] atIndex:(index.row + 1)];
    [[DataController dataStore] createBodyCard:self.currentSpeech andSequence:((int)index.row + 1)];
    
    [_cardCollectionView reloadData];
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
        
        //turn text labels and time incramentor "ON"
        
        [self unhideTextFields];
        [_timeStepper setHidden:NO];
        
        [_cardTitle setUserInteractionEnabled:YES];
        [_point1 setUserInteractionEnabled:YES];
        [_point2 setUserInteractionEnabled:YES];
        [_point3 setUserInteractionEnabled:YES];
        [_point4 setUserInteractionEnabled:YES];
        [_point5 setUserInteractionEnabled:YES];
        [_textView setUserInteractionEnabled:YES];
        [_timeStepper setUserInteractionEnabled:YES];
        
        _textView.backgroundColor = [UIColor whiteColor];
        _cardTitle.backgroundColor = [UIColor whiteColor];
        
        
    } else {
        
        if ([_timeLine isInitialized]) {
            
            //turn text labels and time incramentor "OFF"
            [_cardTitle setUserInteractionEnabled:NO];
            [_point1 setUserInteractionEnabled:NO];
            [_point2 setUserInteractionEnabled:NO];
            [_point3 setUserInteractionEnabled:NO];
            [_point4 setUserInteractionEnabled:NO];
            [_point5 setUserInteractionEnabled:NO];
            [_textView setUserInteractionEnabled:NO];
            [_timeStepper setUserInteractionEnabled:NO];
            
            
            [_timeStepper setHidden:YES];
            [self hideTextFields];
            _cardTitle.backgroundColor = [UIColor clearColor];
            _textView.backgroundColor = [UIColor clearColor];
            
            _speechIsRunning = YES;
            [_timeLine start];
        }
        
    }
}


@end
