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
#import "Card.h"

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
        Speech *speech = [_appDelegate.speeches objectAtIndex:row];
        
        Card *firstCard = speech.cards[0];
        if ([firstCard.title isEqual:@"New Speech"]) {
            [_appDelegate.speeches insertObject:[Speech newSpeech] atIndex:0];
            speech = _appDelegate.speeches[0];
            firstCard = speech.cards[0];
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
    return _appDelegate.speeches.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Speech *speech      = _appDelegate.speeches[indexPath.row];
    Card   *mainCard    = [speech.cards firstObject];
    SpeechCell *cell    = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    cell.speechCellTitle.text       = mainCard.title;
    cell.numberOfCardsLabel.text    = [NSString stringWithFormat:@"%d cards",  (int)speech.cards.count];
    
    return cell;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
