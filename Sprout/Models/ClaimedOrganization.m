//
//  ClaimedOrganization.m
//  Sprout
//
//  Created by laurentsai on 8/4/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "ClaimedOrganization.h"
#import "Helper.h"
@implementation ClaimedOrganization
@dynamic ein; // employer identification number
@dynamic name;
@dynamic category;
@dynamic cause;
@dynamic missionStatement;
@dynamic tagLine;
@dynamic website;
@dynamic image;
@dynamic address;//location object of the org
@dynamic claimedBy;

/**
 Returns the name of the class in parse
 */
+ (nonnull NSString *)parseClassName {
    return @"ClaimedOrganization";
}
+ (void) claimOrganization:(NSString *)ein withName:(NSString *)name withCategory:(NSString*)category withCause:(NSString*)cause withMissionStatement:(NSString*)missionStatement withAddress:(NSString*)address withTagline:(NSString*)tagline withWebsite:(NSString*)website withImage:(UIImage*)image withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    ClaimedOrganization* claimedOrg=[ClaimedOrganization new];
    claimedOrg.ein=ein;
    claimedOrg.name=name;
    claimedOrg.category=category;
    claimedOrg.cause=cause;
    claimedOrg.missionStatement=missionStatement;
    claimedOrg.address=address;
    claimedOrg.tagLine=tagline;
    claimedOrg.website=website;
    claimedOrg.image=[Helper getPFFileFromImage:image withName:name];
    claimedOrg.claimedBy=PFUser.currentUser;
    [claimedOrg saveInBackgroundWithBlock:completion];
}

@end
