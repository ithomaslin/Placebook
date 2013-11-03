//
//  PBServerConnector.h
//  Placebook
//
//  Created by Shaun Dowling on 03/11/2013.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PBServerConnector : NSObject

+ (void)makeRequestForRegion:(CLLocationCoordinate2D)northWest to:(CLLocationCoordinate2D)southEast onCompletion:(void (^)(NSArray *clusters))completion;

@end
