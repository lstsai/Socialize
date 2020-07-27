//
//  Location.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
Object to represent an Location
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSObject
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *streetAddress; 

+ (instancetype)locationWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)addressFromLocation:(Location*)loc;

@end

NS_ASSUME_NONNULL_END
