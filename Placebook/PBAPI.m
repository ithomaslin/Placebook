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
    NSMutableDictionary *locationDict = [[NSMutableDictionary alloc] init];
    [locationDict setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:@"lat"];
    [locationDict setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:@"lng"];

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setObject:[imageData base64EncodedStringWithOptions:0] forKey:@"image"];
    [request setObject:@"jpg" forKey:@"image_format"];
    [request setObject:@"seekr_ios" forKey:@"source"];
    [request setObject:mood forKey:@"mood"];
    [request setObject:locationDict forKey:@"location"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:0
                                                         error:&error];

    NSURL *url = [NSURL URLWithString:@"http://54.217.128.103:3000/posts"];

    NSLog(@"Sending HTTP POST to %@.", url);
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    [postRequest setValue:@"application/json"
       forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"PUT"];
    [postRequest setHTTPBody:jsonData];

    //    NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);

    // Send a synchronous request.
    NSURLResponse * response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:postRequest
                                         returningResponse:&response
                                                     error:&error];

    NSString *lol = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", lol);

    NSLog(@".. HTTP done.");

    if (error)
    {
        NSLog(@"error: %@", error);
        return NO;
    }
    
    return YES;
}

@end
