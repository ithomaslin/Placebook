//
//  SKMapAnnotation.h
//  Placebook
//
//  Created by Shaun Dowling on 03/11/2013.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import <MapKit/MapKit.h>

@class SKCluster;
@interface SKMapAnnotation : MKAnnotationView
{
    UIImageView *_imageView;
    UIImageView *_insideView;
}

@property (nonatomic, retain) SKCluster *cluster;

@end
