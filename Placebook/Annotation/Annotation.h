//
//  Annotation.h
//  
//
//  Created by Valentin Filip on 25/08/2013.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation :  NSObject <MKAnnotation>
{
    NSString *name;
    NSString *title;
    NSString *subTitle;
    CLLocationCoordinate2D coordinate;
    double latitude;
    double longitude;
    UIImage *image;
    UIView *leftCalloutAccessoryView;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (retain, nonatomic) UIView *leftCalloutAccessoryView;

-(id)initWithLatitude:(double)theLatitude andLongitude:(double)theLongitude;

@end
