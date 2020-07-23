//
//  APIManager.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
        
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)getOrganizationsWithCompletion:(NSDictionary*)params completion:(void(^)(NSArray *organizations, NSError *error))completion{

    [self GET:@"https://api.data.charitynavigator.org/v2/Organizations" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *orgs= [Organization orgsWithArray:responseObject];
        completion(orgs, nil);
        NSLog(@"Success getting orgs");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error getting orgs: %@", error.localizedDescription);
        completion(nil,error);
    }];

}
- (void)getOrgsWithEIN:(NSArray*)eins completion:(void(^)(Organization * org, NSError *error))completion{
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"]};
    for(NSString* ein in eins)
    {
        NSString *getString= [NSString stringWithFormat:@"https://api.data.charitynavigator.org/v2/Organizations/%@", ein];
        [self GET:getString parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            Organization *org=[Organization orgWithDictionary:responseObject];
            completion(org,nil);
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error getting org: %@", error.localizedDescription);
            completion(nil,error);
        }];
    }
}
- (void)getOrgImage:(NSString*)orgName completion:(void(^)(NSURL *orgImage, NSError *error))completion{
    NSString *searchTerm= [orgName stringByAppendingString:@" logo"];
    NSDictionary *params= @{@"key":[[NSProcessInfo processInfo] environment][@"Google-api-key"] , @"q": searchTerm, @"cx": @"001132024093895335480:dbqsrizjopq", @"searchType": @"image", @"num": @(1)};
    [self GET:@"https://www.googleapis.com/customsearch/v1" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSURL *imageURL=[NSURL URLWithString:responseObject[@"items"][0][@"image"][@"thumbnailLink"]];
        completion(imageURL, nil);
        
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Error getting search %@", error.localizedDescription);
           completion(nil,error);
    }];
}
@end
