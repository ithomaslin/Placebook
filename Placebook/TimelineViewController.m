//
//  TimelineViewController.m
//  Placebook
//
//  Created by Thomas Lin on 11/3/13.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineCell.h"

@interface TimelineViewController ()

@end

@implementation TimelineViewController

@synthesize timelineArray = _timelineArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityIndicator setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/3.0)];
    [self.view addSubview:_activityIndicator];
    
    [_activityIndicator stopAnimating];
    
//    NSURL *baseURL = [NSURL URLWithString:@"string"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimelineCell";
    TimelineCell *cell = (TimelineCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                               forIndexPath:indexPath];
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"TimelinePush"])
    {
        NSLog(@"Hooray!!");
    }
}

@end
