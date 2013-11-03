//
//  PBAPI.m
//  Placebook
//
//  Created by Tom Hennigan on 02/11/2013.
//  Copyright (c) 2013 Placebook. All rights reserved.
//

#import "PBAPI.h"

@implementation PBAPI

+ (BOOL) addPostWithLocation: (CLLocation *)location andImageData:(NSData *)imageData andMood:(NSNumber *)mood
{
    // TEMP DISABLE
    return NO;
    
    NSMutableDictionary *locationDict = [[NSMutableDictionary alloc] init];
    [locationDict setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:@"lat"];
    [locationDict setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:@"lng"];
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setObject:[imageData base64EncodedStringWithOptions:0] forKey:@"image"];
    [request setObject:@"jpg" forKey:@"image_format"];
    [request setObject:@"seekr_ios" forKey:@"source"];
    [request setObject:mood forKey:@"mood"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:0
                                                         error:&error];

    NSURL *url = [NSURL URLWithString:@"http://tom.gd:1500/"];
    
    NSLog(@"Sending HTTP POST to %@.", url);
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    [postRequest setValue:@"application/x-www-form-urlencoded"
       forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"PUT"];
    [postRequest setHTTPBody:jsonData];
    
    // Send a synchronous request.
    NSURLResponse * response = nil;
    [NSURLConnection sendSynchronousRequest:postRequest
                          returningResponse:&response
                                      error:&error];
    
    NSLog(@".. HTTP done.");
    
    if (error)
    {
        NSLog(@"error: %@", error);
        return NO;
    }
    
    return YES;
}

@end
