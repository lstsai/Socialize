//
//  Organization.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Organization.h"
#import <Parse/Parse.h>
@implementation Organization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {

        self.ein = dictionary[@"ein"];
        self.category=dictionary[@"category"][@"categoryName"];
        self.cause=dictionary[@"cause"][@"causeName"];
        self.imageURL= [NSURL URLWithString:dictionary[@"category"][@"image"]];
        self.name=dictionary[@"charityName"];
        self.location= [Location locationWithDictionary:dictionary[@"mailingAddress"]];

        if(![dictionary[@"mission"] isEqual:[NSNull null]])
            self.missionStatement=dictionary[@"mission"];
            
        if(![dictionary[@"tagLine"] isEqual:[NSNull null]])
            self.tagLine=dictionary[@"tagLine"];
        
        if(![dictionary[@"websiteURL"] isEqual:[NSNull null]])
            self.website=[NSURL URLWithString:dictionary[@"websiteURL"]];
        PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
        [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
        PFObject *userAccess= [friendAccessQ getFirstObject];
        if(userAccess[@"friendOrgs"][self.ein])
            self.numFriendsLike=((NSArray*)userAccess[@"friendOrgs"][self.ein]).count;
        else
            self.numFriendsLike=0;
    }
    return self;

}
//add factory method that returns tweets when initialized with an array of tweet dictionaries
+ (NSMutableArray *)orgsWithArray:(NSArray *)dictionaries{
    NSMutableArray *orgs = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        //create an array of tweets from the big dictionary full of tweets
        Organization *org = [[Organization alloc] initWithDictionary:dictionary];
        [orgs addObject:org];
    }
    return orgs;
}

@end
