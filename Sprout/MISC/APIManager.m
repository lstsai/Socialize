//
//  APIManager.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
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
- (void)getOrgsWithEIN:(NSArray*)eins completion:(void(^)(NSArray * orgs, NSError *error))completion{
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"]};
    NSMutableArray *orgDictionaries= [NSMutableArray new];
    for(NSString* ein in eins)
    {
        NSString *getString= [NSString stringWithFormat:@"https://api.data.charitynavigator.org/v2/Organizations/%@", ein];
        [self GET:getString parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [orgDictionaries addObject:responseObject];
            if([ein isEqualToString:[eins lastObject]])
            {
                NSArray *organizations=[Organization orgsWithArray:orgDictionaries];
                completion(organizations,nil);
            }
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(![error.localizedDescription isEqualToString:@"Request failed: not found (404)"])
                completion(nil,error);
            //if this ein cannot be found, move on to the next one
            if([ein isEqualToString:[eins lastObject]])
            {
                NSArray *organizations=[Organization orgsWithArray:orgDictionaries];
                completion(organizations,nil);
            }
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
- (void)getOrgsNearLocation:(CLLocationCoordinate2D)coords withSearch:(NSString*) search withCompletion:(void(^)(NSArray *orgs, NSError *error))completion{
    NSDictionary *params= @{@"key":[[NSProcessInfo processInfo] environment][@"Google-api-key"] , @"rankby": @"distance", @"location": [NSString stringWithFormat:@"%f,%f", coords.latitude, coords.longitude], @"type": @"fire_station"};

    [self GET:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *cities= [NSMutableArray new];
        NSString* vicinity, *city;
        for(NSDictionary* place in (NSArray*)responseObject[@"results"])
        {
            vicinity=place[@"vicinity"];
            city=[[vicinity componentsSeparatedByString:@","].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//get only the city part of the address
            if(![cities containsObject:city])
                [cities addObject:city];
        }
        NSMutableDictionary *orgParams= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":search, @"rated":@"TRUE", @"pageSize":@(RESULTS_SIZE)}.mutableCopy;
        NSMutableArray* orgResults= [NSMutableArray new];
        for(city in cities)
        {
            orgParams[@"city"]=city;
            [self getOrganizationsWithCompletion:orgParams completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
                if(organizations)
                    [orgResults addObjectsFromArray:organizations];
                if([city isEqualToString:cities.lastObject])
                    completion(orgResults, nil);
            }];
        }

       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Error getting search %@", error.localizedDescription);
           completion(nil,error);
    }];
}
@end
