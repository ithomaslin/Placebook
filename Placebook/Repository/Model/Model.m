//
//  Model.m
//  
//
//  Created by Valentin Filip on 25/08/2013.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "Model.h"

@implementation Model

+ (id)modelWithDict:(NSDictionary *)dict {
    Model *item = [[Model alloc] init];
    item.title = dict[@"title"];
    item.location = dict[@"location"];
    item.date = dict[@"date"];
    item.type = dict[@"type"];
    item.value = dict[@"value"];
    item.cover = dict[@"cover"];
    item.latitude = [dict[@"latitude"] doubleValue];
    item.longitude = [dict[@"longitude"] doubleValue];
    
    return item;
}


@end
