//
//  PBCaptureViewController.h
//  Placebook
//
//  Created by Tom Hennigan on 02/11/2013.
//  Copyright (c) 2013 Placebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>

#include "PBAPI.h"

@interface PBCaptureViewController : UIViewController <CLLocationManagerDelegate>
{

}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) CLLocation *location;

@end
