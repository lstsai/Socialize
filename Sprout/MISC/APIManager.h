//
//  APIManager.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Manages all the API calls for the app
 */

#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>
#import "Organization.h"
NS_ASSUME_NONNULL_BEGIN

@interface APIManager : AFHTTPSessionManager
+ (instancetype)shared;
- (instancetype)init;
- (void)getOrganizationsWithCompletion:(NSDictionary*)params completion:(void(^)(NSArray *organizations, NSError *error))completion;
- (void)getOrgsWithEIN:(NSArray*)eins completion:(void(^)(NSArray * orgs, NSError *error))completion;
- (void)getOrgImage:(NSString*)orgName completion:(void(^)(NSURL *orgImage, NSError *error))completion;
- (void)getOrgsNearLocation:(CLLocationCoordinate2D)coords withSearch:(NSString*) search withCompletion:(void(^)(NSArray *orgs, NSError *error))completion;
- (void)getCoordsFromAddress:(NSString*)address completion:(void(^)(CLLocationCoordinate2D coords, NSError * _Nullable error))completion;
@end

NS_ASSUME_NONNULL_END
