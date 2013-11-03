//
//  WhatsHotViewController.h
//  Placebook
//
//  Created by Thomas Lin on 11/2/13.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WhatsHotViewControllerDelegate;

@interface WhatsHotViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) id<WhatsHotViewControllerDelegate>delegate;

- (IBAction)closeButton:(id)sender;

@end

@protocol WhatsHotViewControllerDelegate <NSObject>

- (void)didChooseHotPlace:(WhatsHotViewController *)indexPath;
@end