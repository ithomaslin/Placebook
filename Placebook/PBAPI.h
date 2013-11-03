//
//  PBAPI.h
//  Placebook
//
//  Created by Tom Hennigan on 02/11/2013.
//  Copyright (c) 2013 Placebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PBAPI.h"

@interface PBAPI : NSObject

+ (BOOL) addPostWithLocation: (CLLocation *)location andImageData:(NSData *)imageData andMood:(NSNumber *)mood;

@end
