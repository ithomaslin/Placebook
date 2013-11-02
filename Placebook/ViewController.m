//
//  ViewController.m
//  Placebook
//
//  Created by Thomas Lin on 11/2/13.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import "ViewController.h"
#import "Annotation.h"
#import "Model.h"

@interface ViewController ()
{
    BOOL bottomViewDown;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    bottomViewDown = YES;
    
    self.mapView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mapPressed:(id)sender {
    
    if (bottomViewDown) {
        [UIView animateWithDuration:0.5f
                              delay:0.1f
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             [_mapView setFrame:CGRectMake(0, 0, _mapView.frame.size.width, 206)];
                             [_bottomView setCenter:CGPointMake(160, 390)];
                         } completion:^(BOOL finished){
                             bottomViewDown = NO;
                         }];
    } else {
        [UIView animateWithDuration:0.5f
                              delay:0.1f
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             [_bottomView setCenter:CGPointMake(160, 700)];
                             [_mapView setFrame:CGRectMake(0, 0, _mapView.frame.size.width, 510)];
                         } completion:^(BOOL finished){
                             bottomViewDown = YES;
                         }];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    // cell customization
    return cell;
    
}
@end
