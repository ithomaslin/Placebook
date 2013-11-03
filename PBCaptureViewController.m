//
//  PBCaptureViewController.m
//  Placebook
//
//  Created by Tom Hennigan on 02/11/2013.
//  Copyright (c) 2013 Placebook. All rights reserved.
//

#import "PBCaptureViewController.h"

@interface PBCaptureViewController () {

    UIButton *__captureButton;
    NSArray *__moods;
    NSArray *__moodBubbles;

    BOOL __choosingBubble;
    BOOL __newBubble;
    NSInteger __chosenBubble;

    // Temporary image data
    CLLocationDegrees __imageLatitude;
    CLLocationDegrees __imageLongitude;
    NSData *__imageData;
}

@end

@implementation PBCaptureViewController

- (id)init
{
    self = [super init];
    if (self) {

        // Create the capture button.
        __captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [__captureButton addTarget:self action:@selector(captureStillImage) forControlEvents:UIControlEventTouchUpInside];
        [__captureButton setBackgroundColor:[UIColor whiteColor]];
        [__captureButton setClipsToBounds:YES];

        [__captureButton.layer setNeedsDisplayOnBoundsChange:YES];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect rect = [self.view frame];

    // Figure out the button size
    CGSize buttonSize = CGSizeMake(60, 60);
    __captureButton.frame = CGRectMake(((rect.size.width / 2) - (buttonSize.width / 2)),
                                       (rect.size.height - buttonSize.height) - 15,
                                       buttonSize.width,
                                       buttonSize.height);

    __captureButton.layer.cornerRadius = buttonSize.width / 2;

    CGFloat color = 0.7f;
    __captureButton.layer.borderColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0f].CGColor;
    __captureButton.layer.borderWidth = 1.0f;

    __captureButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    __captureButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    __captureButton.layer.shadowOpacity = 0.7f;
    __captureButton.layer.shadowRadius = 3.0f;

    CGSize iconSize = CGSizeMake(30, 20);
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraIcon.png"]];
    [iconView setContentMode:UIViewContentModeScaleAspectFill];
    [iconView setClipsToBounds:YES];
    [iconView setFrame:CGRectMake((buttonSize.width - iconSize.width) / 2, ((buttonSize.height - iconSize.height) / 2) - 2, iconSize.width, iconSize.height)];
    [__captureButton addSubview:iconView];

    __captureButton.layer.masksToBounds = NO;

    // Kick off
    [self.locationManager startUpdatingLocation];
    [self startCaptureSession];
    [self startCapturingLocation];

    // We have the preview view in a UIView (rather than just adding the layer to the root view)
    // so that we can easily remove all views by calling removeFromSuperview: on all subviews.
    UIView *previewView = [[UIView alloc] initWithFrame:self.view.frame];
    [self createVideoPreviewLayerInView:previewView];

    [self.view addSubview:previewView];
    [self.view addSubview:__captureButton];

    // Close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize closeButtonSize = CGSizeMake(50, 50);
    closeButton.frame = CGRectMake(15, 15, closeButtonSize.width, closeButtonSize.height);
    [closeButton setBackgroundColor:[UIColor whiteColor]];
    [closeButton.layer setNeedsDisplayOnBoundsChange:YES];
    [closeButton addTarget:self action:@selector(closeCam:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.layer.cornerRadius = closeButtonSize.width / 2.0;

    closeButton.clipsToBounds = YES;
    [self.view addSubview:closeButton];
    UIImageView *closeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close.png"]];
    closeImg.frame = CGRectMake(14, 14, closeImg.frame.size.width, closeImg.frame.size.height);
    [closeButton addSubview:closeImg];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // Kill everything.
    [self.locationManager stopUpdatingLocation];
    [self stopCaptureSession];
}

- (void)closeCam:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)startCapturingLocation
{
    self.locationManager = [[CLLocationManager alloc] init];


    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // Just set the location on this object to the new location.
    self.location = newLocation;
}

- (void)startCaptureSession
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

- (void)stopCaptureSession
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

- (void)captureStillImage
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
    __imageLatitude = self.location.coordinate.latitude;
    __imageLongitude = self.location.coordinate.longitude;

    __imageData = jpegData;

    NSLog(@"Capturing lat=%f lng=%f", __imageLatitude, __imageLongitude);

    // Remove all subviews (e.g. the avcapture preview and the button).
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self stopCaptureSession];

    // Fill the window with the captured image.
    UIImage *image = [[UIImage alloc] initWithData:jpegData];
    UIImageView* thumbView = [[UIImageView alloc] initWithFrame:self.view.frame];
    thumbView.contentMode = UIViewContentModeScaleAspectFill;
    [thumbView setImage:image];
    [thumbView setUserInteractionEnabled:YES];

    // Add a pan gesture listener.
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(panPiece:)];

	[thumbView addGestureRecognizer:gesture];

    // Animate down to a chat head.
    [UIView animateWithDuration: 0.28f animations:^{
        CGSize buttonSize = CGSizeMake(75, 75);
        CGRect windowRect = self.view.frame;

        thumbView.frame = CGRectMake((windowRect.size.width - buttonSize.width) / 2,
                                     (windowRect.size.height - buttonSize.height) / 2,
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

        [self showMoodBubbles];
        [self.view addSubview:thumbView];
    }];
}

#pragma mark - Mood bubbles

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

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (__chosenBubble == -1) {
            CGRect frame = self.view.frame;
            [UIView animateWithDuration:0.15f animations:^{
                [piece setFrame:CGRectMake((frame.size.width - piece.frame.size.width) / 2, (frame.size.height - piece.frame.size.height) / 2, piece.frame.size.width, piece.frame.size.height)];
            }];
            return;
        }

        [PBAPI addPostWithLocation:self.location andImageData:__imageData andMood:[[__moods objectAtIndex:__chosenBubble] objectForKey:@"value"]];

        return;
    }

    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];

    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        CGFloat x = [piece center].x + translation.x;
        CGFloat y = [piece center].y + translation.y;

        [piece setCenter:CGPointMake(x, y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];

        CGFloat tipX = [piece frame].origin.x + ([piece frame].size.width / 2);
        CGFloat tipY = [piece frame].origin.y;

        [__moodBubbles enumerateObjectsUsingBlock:^(UIView *bubble, NSUInteger idx, BOOL *stop) {
            CGRect bubbleFrame = bubble.frame;
            if (tipX > bubbleFrame.origin.x && tipX < (bubbleFrame.origin.x + bubbleFrame.size.width)) {
                if (tipY > bubbleFrame.origin.y && tipY < (bubbleFrame.origin.y + bubbleFrame.size.height)) {
                    if (__chosenBubble != idx) {
                        __chosenBubble = idx;
                        __newBubble = YES;
                    }

                    *stop = YES;
                    return;
                }
            }

            if (__chosenBubble == idx) {
                [UIView animateWithDuration:0.15f animations:^{
                    [self positionBubble:[__moodBubbles objectAtIndex:__chosenBubble] index:__chosenBubble];
                }];

                __chosenBubble = -1;
            }
        }];

        if (__newBubble) {
            int grow_factor = 6;
            [UIView animateWithDuration:0.1f animations:^{
                [__moodBubbles enumerateObjectsUsingBlock:^(UIView *bubble, NSUInteger idx, BOOL *stop) {
                    if (idx == __chosenBubble) {
                        [self positionBubble:bubble index:idx];
                        [bubble setFrame:CGRectMake(bubble.frame.origin.x - grow_factor, bubble.frame.origin.y - grow_factor, bubble.frame.size.width + (grow_factor * 2), bubble.frame.size.height + (grow_factor * 2))];
                        [[bubble layer] setCornerRadius:(bubble.frame.size.width / 2)];
                    }
                    else {
                        [self positionBubble:bubble index:idx];
                    }
                }];
            }];
        }

        __newBubble = NO;
    }
}

- (void)showMoodBubbles
{
    // If it's the first time, create the mood bubbles
    if (!__moodBubbles) {
        NSMutableArray *bubbles = [[NSMutableArray alloc] init];
        NSMutableArray *moods = [[NSMutableArray alloc] init];

        [moods addObject:@{@"image": [UIImage imageNamed:@"mood-0.png"], @"value": [NSNumber numberWithFloat:0.0f] }];
        [moods addObject:@{@"image": [UIImage imageNamed:@"mood-1.png"], @"value": [NSNumber numberWithFloat:0.25f] }];
        [moods addObject:@{@"image": [UIImage imageNamed:@"mood-2.png"], @"value": [NSNumber numberWithFloat:0.50f] }];
        [moods addObject:@{@"image": [UIImage imageNamed:@"mood-3.png"], @"value": [NSNumber numberWithFloat:0.75f] }];
        [moods addObject:@{@"image": [UIImage imageNamed:@"mood-4.png"], @"value": [NSNumber numberWithFloat:1.0f] }];

        CGRect viewFrame = self.view.frame;
        [moods enumerateObjectsUsingBlock:^(NSDictionary *mood, NSUInteger idx, BOOL *stop) {
            UIView *bubble = [[UIView alloc] initWithFrame:CGRectMake(viewFrame.size.width / 2, viewFrame.size.height / 2, 0, 0)];
            [bubble setAlpha:0.0f];
            [bubble.layer setCornerRadius:28.0f];
            [bubble.layer setContents:(id) [[mood objectForKey:@"image"] CGImage]];

            [self positionBubble:bubble index:idx];
            [bubbles addObject:bubble];
        }];

        __moods = [NSArray arrayWithArray:moods];
        __moodBubbles = [NSArray arrayWithArray:bubbles];
    }

    [__moodBubbles enumerateObjectsUsingBlock:^(UIView *bubble, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:bubble];
        [bubble setAlpha:1.0f];
    }];
}

- (void)positionBubble:(UIView *)bubble index:(NSUInteger)idx
{
    int offset = abs((int) idx - 2) * 40;
    int dat_gap = 5;
    
    [bubble setFrame:CGRectMake((idx * 55) + dat_gap + 19, 120 + offset, 55, 55)];
    [[bubble layer] setCornerRadius:(bubble.frame.size.width / 2)];
}

- (void)hideMoodBubbles
{
    
}

@end
