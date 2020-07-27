//
//  Location.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Location.h"

@implementation Location
/**
Creates and returns an Location  from a single dictionary
@param[in] dictionary the dictionary to be converted
@return the Location that was created
*/
+ (instancetype)locationWithDictionary:(NSDictionary *)dictionary{
    Location *loc = [[Location alloc] init];
    loc.city=dictionary[@"city"];
    loc.country=dictionary[@"country"];
    loc.postalCode=dictionary[@"postalCode"];
    loc.state=dictionary[@"stateOrProvince"];
    loc.streetAddress=dictionary[@"streetAddress1"];
    return loc;
}
/**
Creates and returns an formatted address from a location object
@param[in] loc the location to be converted
@return the address string that was created
*/
+ (NSString *)addressFromLocation:(Location*)loc{
    return [NSString stringWithFormat:@"%@ \n%@, %@ %@", loc.streetAddress, loc.city, loc.state, loc.postalCode];
}
@end
