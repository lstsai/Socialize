//
//  Location.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Location.h"

@implementation Location

+ (instancetype)locationWithDictionary:(NSDictionary *)dictionary{
    Location *loc = [[Location alloc] init];
    loc.city=dictionary[@"city"];
    loc.country=dictionary[@"country"];
    loc.postalCode=dictionary[@"postalCode"];
    loc.state=dictionary[@"stateOrProvince"];
    loc.streetAddress=dictionary[@"streetAddress1"];
    return loc;
}

+ (NSString *)addressFromLocation:(Location*)loc{
    return [NSString stringWithFormat:@"%@ \r%@, %@ %@", loc.streetAddress, loc.city, loc.state, loc.postalCode];
}
@end
