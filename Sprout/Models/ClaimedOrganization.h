//
//  ClaimedOrganization.h
//  Sprout
//
//  Created by laurentsai on 8/4/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClaimedOrganization : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *ein; // employer identification number
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *cause;
@property (nonatomic, strong) NSString *missionStatement;
@property (nonatomic, strong) NSString *tagLine;
@property (nonatomic, strong) NSString *website;
@property (nonatomic,strong) PFFileObject *image;
@property (strong, nonatomic) NSString *address;//location object of the org
@property (strong, nonatomic) PFUser *claimedBy;


+ (void) claimOrganization:(NSString *)ein withName:(NSString *)name withCategory:(NSString*)category withCause:(NSString*)cause withMissionStatement:(NSString*)missionStatement withAddress:(NSString*)address withTagline:(NSString*)tagline withWebsite:(NSString*)website withImage:(UIImage*)image withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
