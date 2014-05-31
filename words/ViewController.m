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

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

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
        
        for (Card *card in speech.cards) {
            if ([card.title isEqualToString:@"New Speech"]) {
                speech = [[DataController dataStore] createSpeechItem];
                break;
            }
        }
        
        for (Card *card in speech.cards) {
            if ([card.title isEqualToString:@"New Speech"]) {
                card.title = @"Speech Title";
                NSError *error;
                [card.managedObjectContext save:&error];
                break;
            }
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

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    // Call search controller
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Call search controller
}

@end
