//
//  Organization.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Organization.h"

@implementation Organization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {

        // Is this a re-tweet?
        self.ein = dictionary[@"ein"];
        self.category=dictionary[@"category"][@"categoryName"];
        self.cause=dictionary[@"cause"][@"causeName"];
        self.imageURL= [NSURL URLWithString:dictionary[@"category"][@"image"]];
        self.missionStatement=dictionary[@"mission"];
        self.name=dictionary[@"charityName"];
        if(![dictionary[@"tagLine"] isEqual:[NSNull null]])
            self.tagLine=dictionary[@"tagLine"];
        else
            self.tagLine=@"";
        self.location= [Location locationWithDictionary:dictionary[@"mailingAddress"]];
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

@end
