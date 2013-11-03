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

@interface ViewController () <WhatsHotViewControllerDelegate>
{
    BOOL bottomViewDown;
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
    bottomViewDown = YES;
    
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
    
    NSMutableArray *places = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D place;
    Annotation *ann;
    
    ann = [[Annotation alloc] initWithLatitude:53.482924 andLongitude:-2.200427];
    ann.coordinate = place;
    ann.title = @"Test";
    ann.name = @"ann";
    [places addObject:ann];
    
    Annotation *selfAnnotation = [[Annotation alloc] initWithLatitude:self.location.coordinate.latitude andLongitude:self.location.coordinate.longitude];
    selfAnnotation.name = @"self";
    [_mapView removeAnnotations:_mapView.annotations];
    selfAnnotation.coordinate = _location.coordinate;
    selfAnnotation.title = @"I'm here!";
    [places addObject:selfAnnotation];
    
    [self.mapView addAnnotations:places];
    [_locationManager stopUpdatingLocation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if(annotationView)
        return annotationView;
    else
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        annotationView.canShowCallout = YES;
        if ([((Annotation *)annotation).name isEqualToString:@"self"]) {
            annotationView.image = [UIImage imageNamed:@"self.png"];
            [annotationView.layer setShadowColor:[UIColor blackColor].CGColor];
            [annotationView.layer setShadowOpacity:1.0f];
            [annotationView.layer setShadowRadius:5.0f];
            [annotationView.layer setShadowOffset:CGSizeMake(0, 0)];
            [annotationView setBackgroundColor:[UIColor clearColor]];
        } else {
            annotationView.image = [UIImage imageNamed:@"tab-item-nearby.png"];
//            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:@"NSData"]];
        }
        
        return annotationView;
    }
    return nil;
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
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_mapView setFrame:CGRectMake(0, 0, _mapView.frame.size.width, 205)];
                             [_bottomView setCenter:CGPointMake(160, 395)];
                         } completion:^(BOOL finished){
                             bottomViewDown = NO;
                         }];
    } else {
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
}



- (IBAction)hotButton:(id)sender
{
    if (!bottomViewDown) {
        [UIView animateWithDuration:0.5f
                              delay:0.1f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_bottomView setCenter:CGPointMake(160, 710)];
                             [_mapView setFrame:CGRectMake(0, 0, _mapView.frame.size.width, 520)];
                         } completion:^(BOOL finished){
                             bottomViewDown = YES;
                         }];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"WhatsHotViewController"];
        self.animationController = [[DropAnimationController alloc] init];
        
        controller.transitioningDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"WhatsHotViewController"];
        self.animationController = [[DropAnimationController alloc] init];
        
        controller.transitioningDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
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

- (void)closeTimeline:(TimelineViewController *)timelineViewController
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

- (void)didChooseHotPlace:(WhatsHotViewController *)whatshotVC{

}

@end
