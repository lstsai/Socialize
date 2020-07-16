//
//  APIManager.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "APIManager.h"
#import "Organization.h"
#import "Organization.h"
static NSString * const baseURLString = @"https://api.data.charitynavigator.org/v2/";

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
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    self = [super initWithBaseURL:baseURL];
    if (self) {
        
    }
    return self;
}

- (void)getOrganizationsWithCompletion:(NSDictionary*)params completion:(void(^)(NSArray *organizations, NSError *error))completion{

    [self GET:@"Organizations" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *orgs= [Organization orgsWithArray:responseObject];
        completion(orgs, nil);
        NSLog(@"Success getting orgs");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error getting orgs: %@", error.localizedDescription);
        completion(nil,error);
    }];

}
- (void)getOrgsWithEIN:(NSArray*)eins completion:(void(^)(NSArray *organizations, NSError *error))completion{
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"]};
    NSMutableArray* orgDictionaries=[[NSMutableArray alloc] init];
    for(NSString* ein in eins)
    {
        NSString *getString= [NSString stringWithFormat:@"Organizations/%@", ein];
        [self GET:getString parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [orgDictionaries addObject:responseObject];
            
            if([ein isEqualToString:[eins lastObject]])
            {
                NSArray *organizations=[Organization orgsWithArray:orgDictionaries];
                completion(organizations,nil);
            }
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error getting org: %@", error.localizedDescription);
            completion(nil,error);
        }];
    }
}

@end
