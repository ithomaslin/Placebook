//
//  PBAPI.m
//  Placebook
//
//  Created by Tom Hennigan on 02/11/2013.
//  Copyright (c) 2013 Placebook. All rights reserved.
//

#import "PBAPI.h"

@implementation PBAPI

+ (BOOL) addPostWithLocation: (CLLocation *)location andImageData:(NSData *)imageData andMood:(NSNumber *)mood callback:(void (^)(NSError *error))callbackBlock
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

    static NSOperationQueue *queue;
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
        [queue setName:@"PBAPI NSURLRequest Queue"];
    }

    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSInteger responseCode = [(NSHTTPURLResponse *) response statusCode];

        NSLog(@"%@ %i", responseData, responseCode);
        callbackBlock(connectionError);
    }];

    return YES;
}

@end
