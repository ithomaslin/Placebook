//
//  SKCluster.h
//  Placebook
//
//  Created by Shaun Dowling on 03/11/2013.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SKCluster : NSObject <MKAnnotation>

@property (nonatomic) NSInteger count;
@property (nonatomic) CGPoint center;
@property (nonatomic, strong) NSArray *thumbs;
@property (nonatomic) CGFloat relSize;

@end
