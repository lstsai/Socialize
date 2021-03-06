//
//  OrgCell.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgCell.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"
#import "Helper.h"
@implementation OrgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
 Loads the views of the cell to reflect the represented organization 
 */
-(void) loadData{
    self.nameLabel.text=self.org.name;
    self.tagLineLabel.text=self.org.tagLine;
    self.orgImage.image=nil;
    
    if(self.org.imageURL)//set image if available
    {
        [self.orgImage setImageWithURL:self.org.imageURL];
    }
    else{
        //fetch image if not available, set when complete
        [[APIManager shared] getOrgImage:self.org.name completion:^(NSURL * _Nonnull orgImage, NSError * _Nonnull error) {
            if(orgImage)
            {
                self.org.imageURL=orgImage;
                [self.orgImage setImageWithURL:self.org.imageURL];
            }
        }];
    }
    if([PFUser.currentUser[@"likedOrgs"] containsObject:self.org.ein])
        self.likeButton.selected=YES;
    else
        self.likeButton.selected=NO;
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
    [self checkClaimed];
}
/**
calculates the number of friends that have liked this specific organization
only shows the label if at least one friend has liked it
*/
-(void) getLikes{
    PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
    [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    [friendAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* userAccess=object;
        if(userAccess[@"friendOrgs"][self.org.ein])
        {
            self.org.numFriendsLike=((NSArray*)userAccess[@"friendOrgs"][self.org.ein]).count;
            if(self.org.numFriendsLike>0){
                if(self.org.numFriendsLike==1)
                    self.numLikesLabel.text=[NSString stringWithFormat:@"%lu friend has liked this", self.org.numFriendsLike];
                else
                    self.numLikesLabel.text=[NSString stringWithFormat:@"%lu friends have liked this", self.org.numFriendsLike];
                self.numLikesLabel.alpha=SHOW_ALPHA;
            }
        }
        else
        {
            self.numLikesLabel.alpha=HIDE_ALPHA;
        }
    }];
}
/**
Triggered when the user (un)likes this organization. Calls the Helper method didLikeOrg or
 didUnlikeOrg to update user fields on parse.
 @param[in] sender the UIButton that was tapped
*/
- (IBAction)didTapLike:(id)sender {
    
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [Helper didLikeOrg:self.org sender:nil];

    }
    else{
        self.likeButton.selected=NO;
        [Helper didUnlikeOrg:self.org];

    }
}
-(void) checkClaimed{
    [Helper getClaimedOrgFromEin:self.org.ein withCompletion:^(PFObject * _Nonnull claimedOrg) {
        if(claimedOrg)
        {
            self.claimedOrg=(ClaimedOrganization*)claimedOrg;
            self.nameLabel.text=self.claimedOrg.name;
            self.tagLineLabel.text=self.claimedOrg.tagLine;
            self.orgImage.file=self.claimedOrg.image;
            [self.orgImage loadInBackground];
            [Helper performSelectorInBackground:@selector(addUserToSeenClaimedOrgList:) withObject:claimedOrg];
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
