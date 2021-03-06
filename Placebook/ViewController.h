//
//  ViewController.h
//  Placebook
//
//  Created by Thomas Lin on 11/2/13.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PBCaptureViewController.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIViewControllerTransitioningDelegate>
{
    NSMutableArray *locationArray;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *hotBtn;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) PBCaptureViewController *captureViewController;

@property (retain, nonatomic) NSMutableArray *locationArray;

- (IBAction)mapPressed:(id)sender;
- (IBAction)hotButton:(id)sender;
- (IBAction)locate:(id)sender;
- (IBAction)camLaunch:(id)sender;

- (IBAction)refreshMap;


@end
