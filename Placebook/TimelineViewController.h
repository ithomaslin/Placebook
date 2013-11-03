//
//  TimelineViewController.h
//  Placebook
//
//  Created by Thomas Lin on 11/3/13.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimelineDelegate;

@interface TimelineViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *timelineArray;
}
@property (assign, nonatomic) id<TimelineDelegate>delegate;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain, nonatomic) NSMutableArray *timelineArray;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@protocol TimelineDelegate <NSObject>
@optional
- (void)closeTimeline:(TimelineViewController *)timelineViewController;
@end