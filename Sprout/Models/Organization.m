//
//  Organization.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Organization.h"
#import <Parse/Parse.h>
#import "APIManager.h"
@implementation Organization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {

        self.ein = dictionary[@"ein"];
        self.category=dictionary[@"category"][@"categoryName"];
        self.cause=dictionary[@"cause"][@"causeName"];
        self.name=dictionary[@"charityName"];
        if(dictionary[@"imageURL"])
            self.imageURL=[NSURL URLWithString:dictionary[@"imageURL"]];
        else
            self.imageURL=nil;
        self.location= [Location locationWithDictionary:dictionary[@"mailingAddress"]];
        self.locationDictionary=dictionary[@"mailingAddress"];
        if(![dictionary[@"mission"] isEqual:[NSNull null]])
            self.missionStatement=dictionary[@"mission"];
            
        if(![dictionary[@"tagLine"] isEqual:[NSNull null]])
            self.tagLine=dictionary[@"tagLine"];
        
        if(![dictionary[@"websiteURL"] isEqual:[NSNull null]])
            self.website=[NSURL URLWithString:dictionary[@"websiteURL"]];
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

+ (NSDictionary *) dictionaryWithOrg:(Organization *)org{
    NSDictionary* dictionary= @{@"ein":org.ein, @"category": @{@"categoryName":org.category}, @"cause":  @{@"causeName":org.cause}, @"charityName":org.name, @"imageURL":[org.imageURL absoluteString], @"mailingAddress":org.locationDictionary, @"mission":org.missionStatement, @"tagLine":org.tagLine, @"websiteURL": [org.website absoluteString]};
    return dictionary;
}
+ (Organization *) orgWithDictionary:(NSDictionary *)dictionary{
    Organization *org= [Organization new];
    org=[org initWithDictionary:dictionary];
    return org;
}

@end
