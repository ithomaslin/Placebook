//
//  Annotation.m
//  
//
//  Created by Valentin Filip on 25/08/2013.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize coordinate, latitude, longitude;

-(id)initWithLatitude:(double)theLatitude andLongitude:(double)theLongitude
{
    self = [super init];
    
    if(self)
    {
        self.latitude = theLatitude;
        self.longitude = theLongitude;
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
	CLLocationCoordinate2D coord = {self.latitude, self.longitude};
	return coord;
}

@end
