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
#import "CardCell.h"
#import "Constants.h"

@interface SpeechViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;

@property (nonatomic, weak) Card *currentCard;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *addCardButton;

@property (weak, nonatomic) IBOutlet UITextField *cardTitle;
@property (weak, nonatomic) IBOutlet UITextField *cardPointOne;
@property (weak, nonatomic) IBOutlet UITextField *cardPointTwo;
@property (weak, nonatomic) IBOutlet UITextField *cardPointThree;
@property (weak, nonatomic) IBOutlet UITextField *pointFour;
@property (weak, nonatomic) IBOutlet UITextField *pointFive;

@property (nonatomic, strong) SpeechDeliveryController *speechDeliverController;
@property (nonatomic) CGRect textFieldFrame;
@property (nonatomic) CGRect textViewFrame;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;

@property (weak, nonatomic) IBOutlet UITextView *textView;

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
    _pointFour.delegate                     = self;
    _pointFive.delegate                     = self;
    _cardTitle.delegate                     = self;
    _textView.delegate                      = self;
    [_textView setHidden:YES];
    
    _cardCollectionView.dataSource          = self;
    _cardCollectionView.delegate            = self;
    _cardCollectionView.backgroundColor     = [UIColor whiteColor];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    _textViewFrame = _textView.frame;
    
    [self collectionView:_cardCollectionView didSelectItemAtIndexPath:indexPath];
    
    [self instantiateNewTimeLine];
    
}
- (IBAction)incramentTime:(id)sender
{
    UIStepper *step = sender;
    NSTimeInterval time = step.value * 15;
    _currentCard.runTime = time;
    
    //if the current card has a run time it is edited, else it is not edited
    _currentCard.userEdited = _currentCard.runTime;
    
    int minutes = _currentCard.runTime / 60;
    int seconds = (int)_currentCard.runTime % 60;
    if (seconds != 0) {
        _timeLabel.text     = [NSString stringWithFormat:@"%d minutes %d seconds", minutes, seconds];
    } else {
        _timeLabel.text     = [NSString stringWithFormat:@"%d minutes", minutes];
    }
    
    [_cardCollectionView reloadData];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_cardTitle setHidden:YES];
    [_cardPointOne setHidden:YES];
    [_cardPointTwo setHidden:YES];
    [_cardPointThree setHidden:YES];
    [_pointFour setHidden:YES];
    [_pointFive setHidden:YES];
    
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
    [_pointFour setHidden:NO];
    [_pointFive setHidden:NO];
    
    _currentCard.points[0] = _cardPointOne.text;
    _currentCard.points[1] = _cardPointTwo.text;
    _currentCard.points[2] = _cardPointThree.text;
    _currentCard.points[3] = _pointFour.text;
    _currentCard.points[4] = _pointFive.text;
    _currentCard.title     = _cardTitle.text;
    
    textField.frame = _textFieldFrame;
    [self showActiveTextFields];
    
    [_cardCollectionView reloadData];
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _textViewFrame = textView.frame;
    
    [UIView animateWithDuration:.33 animations:^{
        textView.frame = CGRectMake(textView.frame.origin.x, 0, textView.frame.size.width, textView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    [_cardTitle setHidden:YES];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    switch (_currentCard.type) {
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
    
    Card *card = _currentSpeech.cards[indexPath.row];
    
    int min = card.runTime / 60;
    int sec = (int)card.runTime % 60;
    NSString *partialMin = @"";
    switch (sec) {
        case 15: partialMin = ONE_FORTH;    break;
        case 30: partialMin = ONE_HALF;     break;
        case 45: partialMin = THREE_FORTH;  break;
        default:
            break;
    }
    if (min) {
        cell.timeLabel.text       = [NSString stringWithFormat:@"%d%@ min", min, partialMin];
    } else {
        cell.timeLabel.text       = [NSString stringWithFormat:@"%@ min", partialMin];
    }
    int stringCounter = 0;
    for (NSString *string in card.points) {
        if (![string isEqual:@""]) {
            stringCounter++;
        }
    }
    
    cell.titleLabel.text = card.title;
    cell.pointLabel.text = [NSString stringWithFormat:@"%d points", stringCounter];
    cell.backgroundColor = [UIColor orangeColor];
    
    return cell;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self textViewShouldEndEditing:_textView];

    _currentCard            = _currentSpeech.cards[indexPath.row];
    _timeStepper.value      = _currentCard.runTime / 15;
    
    _cardNumberLabel.text   = [NSString stringWithFormat:@"Card %d", (int)(indexPath.row + 1)];
    
    _timeLabel.text         = [NSString stringWithFormat:@"%d seconds", (int)_currentCard.runTime];
    _cardTitle.text         = _currentCard.title;
    _cardPointOne.text      = _currentCard.points[0];
    _cardPointTwo.text      = _currentCard.points[1];
    _cardPointThree.text    = _currentCard.points[2];
    _pointFour.text         = _currentCard.points[3];
    _pointFive.text         = _currentCard.points[4];
    _textView.text          = @"";
    
    
    int minutes = _currentCard.runTime / 60;
    int seconds = (int)_currentCard.runTime % 60;
    if (seconds != 0) {
        _timeLabel.text     = [NSString stringWithFormat:@"%d minutes %d seconds", minutes, seconds];
    } else {
       _timeLabel.text     = [NSString stringWithFormat:@"%d minutes", minutes];
    }
    
    switch (_currentCard.type) {
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
        
        int min = _currentSpeech.runTime / 60;
        int sec = (int)_currentSpeech.runTime % 60;
        if (sec) {
            string = [NSString stringWithFormat:@"%@\n%d minutes and %d seconds", string, min, sec];
        } else {
            string = [NSString stringWithFormat:@"%@\n%d minutes", string, min];
        }
        _textView.text = string;
        
        //hide all textfields
        [_cardPointOne setHidden:YES];
        [_cardPointTwo setHidden:YES];
        [_cardPointThree setHidden:YES];
        [_pointFour setHidden:YES];
        [_pointFive setHidden:YES];
        _textView.backgroundColor = [UIColor clearColor];
    } else {
        //unhide all textfields
        if (!_speechIsRunning) {
            [_cardPointOne setHidden:NO];
            [_cardPointTwo setHidden:NO];
            [_cardPointThree setHidden:NO];
            [_pointFour setHidden:NO];
            [_pointFive setHidden:NO];
            _textView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (_speechIsRunning) {
        [_textView setHidden:NO];
        //do running stuff
        NSString *editedString = @"";
        NSString *newPointChar = @"*";
        //put all the points into the text view
        for (NSString *string in _currentCard.points) {
            if (![string isEqualToString:@""]) {
                editedString = [NSString stringWithFormat:@"\n%@%@", newPointChar, string];
                _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text, editedString];
            }
        }
    } else {
        [self showActiveTextFields];
        //do editing stuff
        //show the corresponding views
    }
}

-(int)numberOfPointsInCurrentCard
{
    int activePoints = 0;
    for (NSString *string in _currentCard.points) {
        if (![string isEqualToString:@""]) {
            activePoints++;
        }
    }
    return activePoints;
}

-(void)showActiveTextFields
{
    if (_currentCard.type == bodyCard) {
        switch ([self numberOfPointsInCurrentCard]) {
            case 0: [_cardPointTwo setHidden:YES];
                    [_cardPointThree setHidden:YES];
                    [_pointFour setHidden:YES];
                    [_pointFive setHidden:YES];
                    break;
            case 1: [_cardPointThree setHidden:YES];
                    [_pointFour setHidden:YES];
                    [_pointFive setHidden:YES];
                    break;
            case 2: [_pointFour setHidden:YES];
                    [_pointFive setHidden:YES];
                    break;
            case 3: [_pointFive setHidden:YES];
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
    [_timeLine.view removeFromSuperview];
    
    _timeLine = NULL;
    
    if (_speechIsRunning) {
        _timeLine = [TimeLine newTimeLineFromSpeech:_speechDeliverController.speech isSubviewOf:self.view withFrame:CGRectMake(128, 0, 420, 60)];
    } else {
        _timeLine = [TimeLine newTimeLineFromSpeech:_currentSpeech isSubviewOf:self.view withFrame:CGRectMake(128, 0, 420, 60)];
    }
}


-(void)animateTimeLineRefactor
{
    CGRect  originalTimeLineFrame = _timeLine.view.frame;
    
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
        [_cardTitle setUserInteractionEnabled:YES];
        [_cardPointOne setUserInteractionEnabled:YES];
        [_cardPointOne setHidden:NO];
        
        [_cardPointTwo setUserInteractionEnabled:YES];
        [_cardPointTwo setHidden:NO];

        [_cardPointThree setUserInteractionEnabled:YES];
        [_cardPointThree setHidden:NO];

        [_pointFour setUserInteractionEnabled:YES];
        [_pointFour setHidden:NO];

        [_pointFive setUserInteractionEnabled:YES];
        [_pointFive setHidden:NO];

        [_textView setUserInteractionEnabled:YES];
        [_timeStepper setUserInteractionEnabled:YES];
        [_timeStepper setHidden:NO];
        _textView.backgroundColor = [UIColor whiteColor];
        _cardTitle.backgroundColor = [UIColor whiteColor];


    } else {
        //turn text labels and time incramentor "ON"
        [_cardTitle setUserInteractionEnabled:NO];
        [_cardPointOne setUserInteractionEnabled:NO];
        [_cardPointTwo setUserInteractionEnabled:NO];
        [_cardPointThree setUserInteractionEnabled:NO];
        [_pointFour setUserInteractionEnabled:NO];
        [_pointFive setUserInteractionEnabled:NO];
        [_textView setUserInteractionEnabled:NO];
        [_timeStepper setUserInteractionEnabled:NO];
        
        
        [_timeStepper setHidden:YES];
        [_cardPointOne setHidden:YES];
        [_cardPointTwo setHidden:YES];
        [_cardPointThree setHidden:YES];
        [_pointFour setHidden:YES];
        [_pointFive setHidden:YES];

        _cardTitle.backgroundColor = [UIColor clearColor];
        _textView.backgroundColor = [UIColor clearColor];
        
        _speechIsRunning = YES;
        [_timeLine startTimer];
    }
}


@end
