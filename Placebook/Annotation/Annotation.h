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

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;


-(id)initWithLatitude:(double)theLatitude andLongitude:(double)theLongitude;

@end
