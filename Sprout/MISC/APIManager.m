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

//instantiate a shared api manager for all the view controllers
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
/**
 Calls the Charity navigator API for the list of organizations that matches
 the search of the user. Returns that list of orgnaizations.
 @param[in] params The parameters to pass to the API call
 @param[in] completion The completion block to be called when the API call is finished,
 if there is an error, organizations will be nil, else it will return the array of organizations.
*/
- (void)getOrganizationsWithCompletion:(NSDictionary*)params completion:(void(^)(NSArray *organizations, NSError *error))completion{

    [self GET:@"https://api.data.charitynavigator.org/v2/Organizations" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //convert the dictionary objects to organization objects
        NSArray *orgs= [Organization orgsWithArray:responseObject];
        completion(orgs, nil);
        NSLog(@"Success getting orgs");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error getting orgs: %@", error.localizedDescription);
        if(![error.localizedDescription isEqualToString:@"Request failed: not found (404)"])
            completion(nil,error);
        else //the error was that there were no orgs that matched the search
            completion(@[], nil);
    }];

}
/**
 Calls the Charity navigator API for the organizations that matches
 specific employer ID numbers. Returns those orgnaizations.
 @param[in] eins The employer identification numbers to search for
 @param[in] completion The completion block to be called when the API call is finished.
 
 Calls the API for the organizations one by one, when the last call is complete,
 it returns the list of organizations.
*/
- (void)getOrgsWithEIN:(NSArray*)eins completion:(void(^)(NSArray * orgs, NSError *error))completion{
    //the params for the api call
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"]};
    NSMutableArray *orgDictionaries= [NSMutableArray new];
    for(NSString* ein in eins)
    {
        NSString *getString= [NSString stringWithFormat:@"https://api.data.charitynavigator.org/v2/Organizations/%@", ein];
        [self GET:getString parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [orgDictionaries addObject:responseObject];
            if([ein isEqualToString:[eins lastObject]])//only call completion when it is done fetching for orgs
            {
                NSArray *organizations=[Organization orgsWithArray:orgDictionaries];
                completion(organizations,nil);
            }
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(![error.localizedDescription isEqualToString:@"Request failed: not found (404)"])
                completion(nil,error);
            //if this ein cannot be found, move on to the next one
            if([ein isEqualToString:[eins lastObject]])//only call completion when it is done fetching for orgs
            {
                NSArray *organizations=[Organization orgsWithArray:orgDictionaries];
                completion(organizations,nil);
            }
        }];
    }
}
/**
 Calls the Google custom search API to look for an image of the organization's logo. Returns the first
 image result the matches the search "<org name> logo"
 @param[in] orgName The name of the organization to search for
 @param[in] completion The completion block to be called when the API call is finished, sends the image, or an error.
*/
- (void)getOrgImage:(NSString*)orgName completion:(void(^)(NSURL *orgImage, NSError *error))completion{
    NSString *searchTerm= [orgName stringByAppendingString:@" logo"];
    NSDictionary *params= @{@"key":[[NSProcessInfo processInfo] environment][@"Google-api-key"] , @"q": searchTerm, @"cx": @"001132024093895335480:hdk45weoe1u", @"searchType": @"image", @"num": @(1)};
    [self GET:@"https://www.googleapis.com/customsearch/v1" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSURL *imageURL=[NSURL URLWithString:responseObject[@"items"][0][@"image"][@"thumbnailLink"]];
        completion(imageURL, nil);
        
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Error getting search %@", error.localizedDescription);
           completion(nil,error);
    }];
}
/**
 Calls the GeoDB Cities API to find cities close to the search location in order to perform
 more searches for organizations in nearby locations.
 @param[in] coords the coordinate of the original search
 @param[in] search the search term for the organizations
 @param[in] completion The completion block to be called when the API call is finished, sends orgnaizations, or an error.
*/
- (void)getOrgsNearLocation:(CLLocationCoordinate2D)coords withSearch:(NSString*) search withCompletion:(void(^)(NSArray *orgs, NSError *error))completion{
    //params for the geodb api call, sort by population high to low
    NSDictionary *params= @{@"radius":@(SEARCH_RADIUS), @"limit": @(MIN_RESULT_THRESHOLD), @"sort":@"-population"};
    NSString* getString=[NSString stringWithFormat:@"http://geodb-free-service.wirefreethought.com/v1/geo/locations/%f%f/nearbyCities", coords.latitude, coords.longitude];
    [self GET:getString parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *cities= [NSMutableArray new];
        NSString* state;
        //add the name of the city to an array. exclude county results
        for(NSDictionary* place in (NSArray*)responseObject[@"data"])
        {
            if ([place[@"city"] rangeOfString:@"County"].location == NSNotFound)
                [cities addObject:place[@"city"]];
            state=place[@"regionCode"];
        }
        //params for the charity navigator api.
        NSMutableDictionary *orgParams= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":search, @"state":state, @"rated":@"TRUE", @"pageSize":@(RESULTS_SIZE)}.mutableCopy;
        NSMutableArray* orgResults= [NSMutableArray new];
        //search for more organizations matching search in near cities, call api and append to results
        for(NSString* city in cities)
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
/**
 Calls the GoogleMaps Geocoding API to convert a street address into it's coordinates
 @param[in] address the address to convert
 @param[in] completion the block to execute when finished
 */
- (void)getCoordsFromAddress:(NSString*)address completion:(void(^)(CLLocationCoordinate2D coords, NSError * _Nullable error))completion{
    NSDictionary *params= @{@"key":[[NSProcessInfo processInfo] environment][@"Google-api-key"] , @"address":address};
    [self GET:@"https://maps.googleapis.com/maps/api/geocode/json" parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* location= [responseObject[@"results"] firstObject][@"geometry"][@"location"];
        CLLocationCoordinate2D coord= CLLocationCoordinate2DMake([location[@"lat"] doubleValue], [location[@"lng"] doubleValue]);
        completion(coord, nil);
        
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Error getting search %@", error.localizedDescription);
           CLLocationCoordinate2D coord=CLLocationCoordinate2DMake(0, 0);
           completion(coord,error);
    }];
}
@end
