//
//  ViewController.m
//  Placebook
//
//  Created by Thomas Lin on 11/2/13.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import "ViewController.h"
#import "Annotation.h"
#import "WhatsHotViewController.h"
#import "ZoomAnimationController.h"
#import "ADVAnimationController.h"
#import "DropAnimationController.h"
#import "TimelineViewController.h"
#import "WhatsHotViewController.h"
#import "PBServerConnector.h"
#import "SKCluster.h"
#import "SKMapAnnotation.h"

@interface ViewController () <WhatsHotViewControllerDelegate>
{
    BOOL bottomViewDown;
    CGFloat _mapDelta;
    MKCoordinateRegion _region;
    CGFloat _spanDelta;
}

@property (nonatomic, strong) id<ADVAnimationController> animationController;
@property (nonatomic, retain) NSMutableArray *placeArray;

@end

@implementation ViewController

@synthesize locationArray;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _mapDelta = 0.0;
    _spanDelta = 0.0;
    
    bottomViewDown = YES; //Timeline view is hidden...
    
    //Shadow for hot button...
    [_hotBtn.layer setShadowColor:[UIColor blackColor].CGColor];
    [_hotBtn.layer setShadowOpacity:1.0f];
    [_hotBtn.layer setShadowRadius:5.0f];
    [_hotBtn.layer setShadowOffset:CGSizeMake(0, 0)];
    [_hotBtn setBackgroundColor:[UIColor clearColor]];
    
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
    
    self.locationManager.delegate = self;
    self.location = [[CLLocation alloc] init];
    
    if (_mapDelta == 0)
        [self refreshMap];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _region = mapView.region;
    
    NSLog(@"Started at %@", NSStringFromCGPoint(CGPointMake(_region.center.latitude, _region.center.longitude)));
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    _mapDelta = fabs(_region.center.longitude - mapView.centerCoordinate.longitude) + fabs(_region.center.latitude - mapView.centerCoordinate.latitude);
    
    _spanDelta = fabs(_region.span.longitudeDelta - mapView.region.span.longitudeDelta) + fabs(_region.span.latitudeDelta - mapView.region.span.latitudeDelta);
    
    NSLog(@"Comparing %@", NSStringFromCGPoint(CGPointMake(_region.center.latitude, _region.center.longitude)));
    NSLog(@"Ended at %@", NSStringFromCGPoint(CGPointMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude)));
    
    NSLog(@"delta: %f\n", _mapDelta);
    NSLog(@"span delta: %f\n", _spanDelta);
    
    if (_mapDelta > 1e-3 || _spanDelta > 1e-3)
        [self refreshMap];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.location = locations.lastObject;
    MKCoordinateRegion region;
    float latitude = self.location.coordinate.latitude;
    float longitude = self.location.coordinate.longitude;
    region.span.latitudeDelta = 1.0/50*0.9;
    region.span.longitudeDelta = 1.0/50*0.9;
    region.center.latitude = latitude;
    region.center.longitude = longitude;
    
    [_mapView setRegion:region animated:YES];
    [_mapView regionThatFits:region];
    
    //User location...
    Annotation *selfAnnotation = [[Annotation alloc] initWithLatitude:self.location.coordinate.latitude andLongitude:self.location.coordinate.longitude];
    selfAnnotation.name = @"self";
    [_mapView removeAnnotations:_mapView.annotations];
    selfAnnotation.coordinate = _location.coordinate;
    selfAnnotation.title = @"I'm here!";
    
    [self.mapView addAnnotation:selfAnnotation];
    [_locationManager stopUpdatingLocation];
    
}

//- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation
//{
////    if ([annotation isKindOfClass:[MKUserLocation class]])
////        return nil;
//    
//    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
//    MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
//    if(annotationView)
//        return annotationView;
//    else
//    {
//        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
//        annotationView.canShowCallout = YES;
//        if ([annotation isKindOfClass:[Annotation class]]) {
//            annotationView.image = [UIImage imageNamed:@"self.png"];
//        } else {
//            annotationView.image = [UIImage imageNamed:@"tab-item-nearby.png"];
////            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:@"NSData"]];
//            //Set pic on the annotation...
//        }
//        [annotationView.layer setShadowColor:[UIColor blackColor].CGColor];
//        [annotationView.layer setShadowOpacity:1.0f];
//        [annotationView.layer setShadowRadius:5.0f];
//        [annotationView.layer setShadowOffset:CGSizeMake(0, 0)];
//        [annotationView setBackgroundColor:[UIColor clearColor]];
//        
//        return annotationView;
//    }
//    return nil;
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView* aView;
    
    if ([annotation isKindOfClass:[Annotation class]]) {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                reuseIdentifier:@"MyCustomAnnotation"];
        aView.centerOffset = CGPointMake(10, -20);
        aView.image = [UIImage imageNamed:@"self.png"];
    } else {
        SKMapAnnotation *anotherView = [[SKMapAnnotation alloc] initWithAnnotation:annotation
                                             reuseIdentifier:@"OtherCustomAnnotation"];
        anotherView.cluster = (SKCluster *)annotation;
        [anotherView setNeedsDisplay];
        aView = anotherView;
    }

    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)refreshMap
{    
    CLLocationCoordinate2D northWestCorner = [self.mapView convertPoint:self.mapView.frame.origin toCoordinateFromView:_mapView];
    
    CLLocationCoordinate2D southEastCorner = [self.mapView convertPoint:CGPointMake(CGRectGetMaxX(self.mapView.frame), CGRectGetMaxY(self.mapView.frame)) toCoordinateFromView:_mapView];
    
    CGFloat sizeLat = southEastCorner.latitude - northWestCorner.latitude;
    CGFloat sizeLong = southEastCorner.longitude - northWestCorner.longitude;
    
    northWestCorner.latitude -= sizeLat * 0.1;
    southEastCorner.latitude += sizeLat * 0.1;
    
    northWestCorner.longitude -= sizeLong * 0.1;
    southEastCorner.longitude += sizeLong * 0.1;
    
    [PBServerConnector makeRequestForRegion:northWestCorner to:southEastCorner onCompletion:^(NSArray *clusters) {
        
        NSArray *annotations = [_mapView.annotations copy];
        for (id<MKAnnotation> annotation in annotations) {
            if (![annotation isKindOfClass:[Annotation class]])
                [self.mapView removeAnnotation:annotation];
        }
        // Add all those to the map
        for (SKCluster *cluster in clusters)
            [self.mapView addAnnotation:cluster];
    }];
}

- (IBAction)mapPressed:(id)sender {
    if (bottomViewDown) {
        [self openTimeline];
    } else {
        [self closeTimeline];
    }
}

- (void)openTimeline
{
    [UIView animateWithDuration:0.5f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_mapView setFrame:CGRectMake(0, 0, _mapView.frame.size.width, 205)];
                         [_bottomView setCenter:CGPointMake(160, 395)];
                     } completion:^(BOOL finished){
                         bottomViewDown = NO;
                     }];
}

- (void)closeTimeline
{
    [UIView animateWithDuration:0.5f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_bottomView setCenter:CGPointMake(160, 710)];
                         [_mapView setFrame:CGRectMake(0, 0, _mapView.frame.size.width, 520)];
                     } completion:^(BOOL finished){
                         bottomViewDown = YES;
                     }];
}

- (void)showHotView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"WhatsHotViewController"];
    self.animationController = [[DropAnimationController alloc] init];
    
    controller.transitioningDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)hotButton:(id)sender
{
    if (!bottomViewDown) {
        [self closeTimeline];
        [self showHotView];
       
    } else {
        [self showHotView];
    }
}

- (IBAction)locate:(id)sender {
    MKCoordinateRegion region;
    float latitude = self.location.coordinate.latitude;
    float longitude = self.location.coordinate.longitude;
    region.span.latitudeDelta = 1.0/50*0.9;
    region.span.longitudeDelta = 1.0/50*0.9;
    region.center.latitude = latitude;
    region.center.longitude = longitude;
    
    [_mapView setRegion:region animated:YES];
    [_mapView regionThatFits:region];
}

- (IBAction)camLaunch:(id)sender
{
    _captureViewController = [[PBCaptureViewController alloc] init];
    [self presentViewController:_captureViewController animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.animationController.isPresenting = YES;
    return self.animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animationController.isPresenting = NO;
    
    return self.animationController;
}

- (void)didChooseHotPlace:(WhatsHotViewController *)whatshotVC{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
