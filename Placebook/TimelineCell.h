//
//  TimelineCell.h
//  Placebook
//
//  Created by Thomas Lin on 11/3/13.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *placeImage;
@property (strong, nonatomic) IBOutlet UIImageView *moodImage;
@property (strong, nonatomic) IBOutlet UITextView *textField;

@end
