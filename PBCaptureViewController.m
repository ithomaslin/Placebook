//
//  PBCaptureViewController.m
//  Placebook
//
//  Created by Tom Hennigan on 02/11/2013.
//  Copyright (c) 2013 Placebook. All rights reserved.
//

#import "PBCaptureViewController.h"

@implementation PBCaptureViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id) init
{
    self = [super init];
    
    // Create the capture button.
    UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect windowRect = [self.view frame];
    CGSize buttonSize = CGSizeMake(100, 100);
    captureButton.frame = CGRectMake(((windowRect.size.width / 2) - (buttonSize.width / 2)),
                                     (windowRect.size.height - buttonSize.height) - 15,
                                     buttonSize.width,
                                     buttonSize.height);
    [captureButton setBackgroundColor:[UIColor whiteColor]];
    [captureButton.layer setNeedsDisplayOnBoundsChange:YES];
    [captureButton addTarget:self action:@selector(captureStillImage) forControlEvents:UIControlEventTouchUpInside];
    captureButton.clipsToBounds = YES;
    captureButton.layer.cornerRadius = buttonSize.width / 2;
    CGFloat color = 0.7f;
    captureButton.layer.borderColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0f].CGColor;
    captureButton.layer.borderWidth = 2.0f;
    captureButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    captureButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    captureButton.layer.shadowOpacity = 0.9f;
    captureButton.layer.shadowRadius = 3.0f;
    captureButton.layer.masksToBounds = NO;
    [self.view addSubview:captureButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize closeButtonSize = CGSizeMake(50, 50);
    closeButton.frame = CGRectMake(15, 15, closeButtonSize.width, closeButtonSize.height);
    [closeButton setBackgroundColor:[UIColor whiteColor]];
    [closeButton.layer setNeedsDisplayOnBoundsChange:YES];
    [closeButton addTarget:self action:@selector(closeCam:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.layer.cornerRadius = buttonSize.width / 4.2;
    closeButton.clipsToBounds = YES;
    [self.view addSubview:closeButton];
    UIImageView *closeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close.png"]];
    closeImg.frame = CGRectMake(14, 14, closeImg.frame.size.width, closeImg.frame.size.height);
    [closeButton addSubview:closeImg];

    return self;
}

- (void) startCapturingLocation
{
    // Kick off the location manager.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // Just set the location on this object to the new location.
    self.location = newLocation;
}

- (void) startCaptureSession
{
    // Create an AVCaptureSession.
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    
    // Find the back facing camera.
    AVCaptureDevice *device;
    for (AVCaptureDevice *candidateDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([candidateDevice position] == AVCaptureDevicePositionBack) {
            device = candidateDevice;
            break;
        }
    }

    if (device == nil) {
        NSLog(@"Unable to find camera.");
        exit(1);
    }

    // Create an input device to revieve video frames (for the preview).
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!input) {
        NSLog(@"Couldn't create video capture device");
        NSLog(@"%@", error);
        exit(1);
    }
    
    // Create an output device to get stills from.
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.captureSession addInput:input];
    [self.captureSession addOutput:self.stillImageOutput];
    
    // Kick it all off.
    [self.captureSession startRunning];
}

- (void) stopCaptureSession
{
    [self.captureSession stopRunning];
}

- (CALayer *)createVideoPreviewLayerInView: (UIView *)view;
{
    CALayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    videoPreviewLayer.frame = self.view.frame;
    
    [view.layer addSublayer:videoPreviewLayer];
    [view setNeedsDisplay];
    
    return videoPreviewLayer;
}

- (void) captureStillImage
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [self.stillImageOutput connections]) {
        NSLog(@"connection: %@", connection);
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    if (!videoConnection) {
        NSLog(@"Couldn't establish video connection.");
        NSLog(@"%@", videoConnection);
        exit(1);
    }
    
    NSLog(@"%@", @"About to capture a still.");
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         // Grab the image as a JPEG
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         [self didCaptureImage:imageData];
     }];
}

- (void)didCaptureImage:(NSData *)jpegData
{
    CLLocationDegrees latitude = self.location.coordinate.latitude;
    CLLocationDegrees longitude = self.location.coordinate.longitude;
    
    NSLog(@"lat=%f lng=%f", latitude, longitude);
    
    // Send HTTP request (synchronous).
//    [PBAPI addPostWithLocation:self.location andImageData:jpegData andMood:[NSNumber numberWithFloat:0.5f]];
    
    // Remove all subviews (e.g. the avcapture preview and the button).
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self stopCaptureSession];

    // Fill the window with the captured image.
    UIImage *image = [[UIImage alloc] initWithData:jpegData];
    UIImageView* thumbView = [[UIImageView alloc] initWithFrame:self.view.frame];
    thumbView.contentMode = UIViewContentModeScaleAspectFill;
    [thumbView setImage:image];
    [thumbView setUserInteractionEnabled:YES];
    
    [self.view addSubview:thumbView];
    
    // Add a pan gesture listener.
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(panPiece:)];
	[thumbView addGestureRecognizer:gesture];
    
    // Animate down to a chat head.
    [UIView animateWithDuration: 0.4f animations:^{
        CGSize buttonSize = CGSizeMake(100, 100);
        CGRect windowRect = self.view.frame;
        thumbView.frame = CGRectMake(((windowRect.size.width / 2) - (buttonSize.width / 2)),
                                         (windowRect.size.height - buttonSize.height) - 15,
                                         buttonSize.width,
                                         buttonSize.height);
        thumbView.clipsToBounds = YES;
        thumbView.layer.cornerRadius = buttonSize.width / 2;
        CGFloat color = 0.7f;
        thumbView.layer.borderColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0f].CGColor;
        thumbView.layer.borderWidth = 2.0f;
        thumbView.layer.shadowColor = [[UIColor blackColor] CGColor];
        thumbView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        thumbView.layer.shadowOpacity = 0.9f;
        thumbView.layer.shadowRadius = 3.0f;
        thumbView.layer.masksToBounds = YES;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Kick off
    [self.locationManager startUpdatingLocation];
    [self startCaptureSession];
    [self startCapturingLocation];
    
    // We have the preview view in a UIView (rather than just adding the layer to the root view)
    // so that we can easily remove all views by calling removeFromSuperview: on all subviews.
    UIView *previewView = [[UIView alloc] initWithFrame:self.view.frame];
    [self createVideoPreviewLayerInView:previewView];
    [self.view addSubview:previewView];
}

- (void)closeCam:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // Kill everything.
    [self.locationManager stopUpdatingLocation];
    [self stopCaptureSession];
}

#pragma mark gestures

/*
 This is largely based on code from: https://developer.apple.com/library/ios/samplecode/Touches/Listings/Touches_Responder_Touches_APLViewController_m.html#//apple_ref/doc/uid/DTS40007435-Touches_Responder_Touches_APLViewController_m-DontLinkElementID_14
 
 The gesture recognizer is only bound to the "chat head" UIImageView, which is instantiated
 during didCaptureImage:. We could improve the feel using a curve similar to the one from
 https://github.com/brutella/chatheads
*/

/**
 Scale and rotation transforms are applied relative to the layer's anchor point this method moves a gesture recognizer's view's anchor point between the user's fingers.
 */
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

/**
 Shift the piece's center by the pan amount.
 Reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position.
 */
- (IBAction)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
    
}

- (void)swipeUp:(id)sender
{
    
}

@end
