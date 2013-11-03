//
//  PBServerConnector.m
//  Placebook
//
//  Created by Shaun Dowling on 03/11/2013.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import "PBServerConnector.h"
#import "SKCluster.h"

@implementation PBServerConnector

+ (void)makeRequestForRegion:(CLLocationCoordinate2D)northWest to:(CLLocationCoordinate2D)southEast onCompletion:(void (^)(NSArray *clusters))completion
{
    /*
     curl -X GET http://54.217.128.103:3000/posts  -H "Content-Type: application/json" -d '{"top_left": {"lat":51.51323, "lon":-0.126171},
     "bottom_right": {"lat":51.503186, "lon":-0.106945}}'
     */
    
    NSDictionary *dataDict = @{@"top_left":
                                   @{@"lat": [NSNumber numberWithFloat:northWest.latitude], @"lon": [NSNumber numberWithFloat:northWest.longitude]},
                               @"bottom_right": @{@"lat":[NSNumber numberWithFloat:southEast.latitude], @"lon": [NSNumber numberWithFloat:southEast.longitude]}
                               };
    
    NSError *err;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&err];
    
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://54.217.128.103:3000/clusters"]];
    
//    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:3000/clusters"]];
    
    
    // Set the request's content type to application/x-www-form-urlencoded
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:[NSString stringWithFormat:@"%i", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setHTTPBody:bodyData];
    
    __block NSMutableArray *clusters = [NSMutableArray array];;
    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSString *output = [[NSString alloc] initWithData:data                                                                        encoding:NSUTF8StringEncoding];
                               
                               NSLog(@"%@", output);
                               if (data != nil) {
                                   NSArray *clusterObject = [NSJSONSerialization JSONObjectWithData: data
                                                                                            options: NSJSONReadingMutableContainers
                                                                                              error: &error];
                                   
                                   @try {
                                       for (NSDictionary *clusterDict in clusterObject) {
                                           SKCluster *cluster = [[SKCluster alloc] init];
                                           cluster.center = CGPointMake([clusterDict[@"center"][@"lat"] floatValue], [clusterDict[@"center"][@"lon"] floatValue]);
                                           cluster.count = [clusterDict[@"total"] integerValue];
                                           cluster.thumbs = clusterDict[@"thumbs"];
                                           [clusters addObject:cluster];
                                       }
                                       completion(clusters);
                                   }
                                   @catch (NSException *exception)
                                   {
                                       NSLog(@"%@", exception);
                                   }
                               }
                           }];
}

@end
