//
//  SKCluster.m
//  Placebook
//
//  Created by Shaun Dowling on 03/11/2013.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import "SKCluster.h"

@implementation SKCluster

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(_center.x, _center.y);
}

@end
