//
//  ViewController.m
//  words
//
//  Created by Christopher Cohen on 5/23/14.
//  Copyright (c) 2014 Christopher Cohen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "SpeechViewController.h"
#import "SpeechCell.h"
#import "Constant.h"
#import "DataController.h"
#import "SpeechController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *searchCollectionView;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITextView *stuff;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;

    _searchCollectionView.dataSource    = self;
    _searchCollectionView.delegate      = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SpeechDetail"]) {
        NSInteger row = [_searchCollectionView indexPathForCell:sender].row;
        Speech *speech = [[[DataController dataStore] allSpeechItems] objectAtIndex:row];
        
        // Obtain the title card by searching the cards set for one with the sequence value of 1
        Card *firstCard = [[[DataController dataStore] allCardItems:speech] firstObject];
        
        if ([firstCard.title isEqual:@"New Speech"]) {
#warning What should happen here?
            // Obtain the title card by searching the cards set for one with the sequence value of 1
            //NSPredicate *findTitleCard = [NSPredicate predicateWithFormat:@"sequence == %i", 1];
            firstCard = [[[DataController dataStore] allCardItems:speech] firstObject];

            firstCard.title =@"Speech Title";
        }
        
        SpeechViewController *speechVC = segue.destinationViewController;
        speechVC.currentSpeech = speech;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_searchCollectionView reloadData];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{    
    return [[[DataController dataStore] allSpeechItems] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Speech *speech          = [[[DataController dataStore] allSpeechItems] objectAtIndex:indexPath.row];
    Card   *mainCard        = [[[DataController dataStore] allCardItems:speech] firstObject];
    SpeechCell *cell        = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    cell.speechCellTitle.text       = mainCard.title;
    cell.numberOfCardsLabel.text    = [NSString stringWithFormat:@"%d cards",  (int)speech.cards.count];
    NSTimeInterval timeInterval = [SpeechController calculateTotalTime:speech];
    int min = timeInterval / 60;
    int sec = (int)timeInterval % 60;
    NSString *partialMin = @"";
    switch (sec) {
        case 15: partialMin = ONE_FORTH;    break;
        case 30: partialMin = ONE_HALF;     break;
        case 45: partialMin = THREE_FORTH;  break;
        default:
            break;
    }
    cell.speechTimeLabel.text       = [NSString stringWithFormat:@"%d%@ min", min, partialMin];
    
    return cell;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
