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

/**
 Creates and returns an Organization object from a dictionary
 @param[in] dictionary the dictronary containing the information for the organization
@return the created organization object
 */
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
        if(![dictionary[@"mission"] isEqual:[NSNull null]]){
            self.missionStatement=dictionary[@"mission"];
            self.missionStatement=[self.missionStatement stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        }
        if(![dictionary[@"tagLine"] isEqual:[NSNull null]])
            self.tagLine=dictionary[@"tagLine"];
        
        if(![dictionary[@"websiteURL"] isEqual:[NSNull null]])
            self.website=[NSURL URLWithString:dictionary[@"websiteURL"]];
    }    
    return self;

}

/**
 Creates and returns an array of Organizations object from an array of  dictionaries
 @param[in] dictionaries the array of dictronaries containing the information for the organizations
 @return the array of organization objects
 */
+ (NSMutableArray *)orgsWithArray:(NSArray *)dictionaries{
    NSMutableArray *orgs = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        //create an array of tweets from the big dictionary full of tweets
        Organization *org = [[Organization alloc] initWithDictionary:dictionary];
        [orgs addObject:org];
    }
    return orgs;
}
/**
Creates and returns an dictionary  from an Organization so that It can be stored in Parse
@param[in] org the Organization to be converted
@return the dictionary conversion of the org
*/
+ (NSDictionary *) dictionaryWithOrg:(Organization *)org{
    NSDictionary* dictionary= @{@"ein":org.ein, @"category": @{@"categoryName":org.category}, @"cause":  @{@"causeName":org.cause}, @"charityName":org.name, @"imageURL":[org.imageURL absoluteString], @"mailingAddress":org.locationDictionary, @"mission":org.missionStatement, @"tagLine":org.tagLine, @"websiteURL": [org.website absoluteString]};
    return dictionary;
}

/**
Creates and returns an Organization from a single dictionary
@param[in] dictionary the dictionary to be converted
@return the org that was created 
*/
+ (Organization *) orgWithDictionary:(NSDictionary *)dictionary{
    Organization *org= [Organization new];
    org=[org initWithDictionary:dictionary];
    return org;
}

@end
