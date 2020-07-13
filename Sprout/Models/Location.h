//
//  Location.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSObject
@property (nonatomic, strong) NSString *city; // For favoriting, retweeting & replying
@property (nonatomic, strong) NSString *country; // Text content of tweet
@property (nonatomic, strong) NSString *postalCode; // Text content of tweet
@property (nonatomic, strong) NSString *state; // Text content of tweet
@property (nonatomic, strong) NSString *streetAddress; // Text content of tweet

+ (instancetype)locationWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
