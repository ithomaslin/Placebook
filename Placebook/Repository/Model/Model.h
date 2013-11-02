//
//  Model.h
//  
//
//  Created by Valentin Filip on 25/08/2013.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//



@interface Model : NSObject

@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *location;
@property (nonatomic, copy) NSDate      *date;
@property (nonatomic, copy) NSString    *type;
@property (nonatomic, copy) NSNumber    *value;
@property (nonatomic, copy) NSString    *cover;
@property (nonatomic, assign) double     latitude;
@property (nonatomic, assign) double     longitude;

+ (id)modelWithDict:(NSDictionary *)dict;

@end
