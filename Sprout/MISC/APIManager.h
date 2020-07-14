//
//  APIManager.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : AFHTTPSessionManager
+ (instancetype)shared;
- (instancetype)init;
- (void)getOrganizationsWithCompletion:(NSDictionary*)params completion:(void(^)(NSArray *organizations, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END