//
//  OrgPostCell.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgPostCell.h"
#import "DateTools.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
@implementation OrgPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
 Loads the views of the cell to represent the post
 */
-(void) loadData{
    //add a tap gesture recognizer so user can tap on the profile image and be taken to the profile page
    UIGestureRecognizer *profileTapGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage setUserInteractionEnabled:YES];
    [self.profileImage addGestureRecognizer:profileTapGesture];
    
    self.nameLabel.text=self.post.author.username;
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.file=self.post.author[@"profilePic"];
    [self.profileImage loadInBackground];
    self.postDescriptionLabel.text=self.post.postDescription;
    self.timeLabel.text=[self.post.createdAt shortTimeAgoSinceNow];
    
    //convert the dictionary back into a organization
    self.org= [Organization orgWithDictionary:(NSDictionary*) self.post.org];
    
    [self.orgImage setImageWithURL:self.org.imageURL];
    [self setShadow];

    self.orgNameLabel.text=self.org.name;
    self.orgTaglineLabel.text=self.org.tagLine;
    self.locationLabel.text=[self.org.location.city stringByAppendingFormat:@", %@", self.org.location.state];
    
    self.likeButton.selected=[PFUser.currentUser[@"likedOrgs"] containsObject:self.org.ein];
    
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
}
/**
 setup the shadoes and rounded cell corners
 */
-(void) setShadow{
    self.orgContainer.layer.cornerRadius = CELL_CORNER_RADIUS*2;
    self.orgContainer.layer.borderColor = [UIColor clearColor].CGColor;
    self.orgContainer.layer.masksToBounds = YES;
    self.orgContainer.clipsToBounds = YES;
    self.orgContainer.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.orgContainer.layer.shadowOffset = CGSizeMake(SHADOW_OFFSET/2, SHADOW_OFFSET/2);
    self.orgContainer.layer.shadowRadius = SHADOW_RADIUS;
    self.orgContainer.layer.shadowOpacity = SHADOW_OPACITY;
    self.orgContainer.layer.masksToBounds = NO;

}
/**
Calculates the number of friends that have liked the organization the post is about
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
                    self.numLikeLabel.text=[NSString stringWithFormat:@"%lu friend has liked this", self.org.numFriendsLike];
                else
                    self.numLikeLabel.text=[NSString stringWithFormat:@"%lu friends have liked this", self.org.numFriendsLike];
                self.numLikeLabel.alpha=SHOW_ALPHA;
            }
        }
        else
        {
            self.numLikeLabel.alpha=HIDE_ALPHA;
        }
    }];
}
/**
 Triggered when the user taps on the user profile image
 @param[in] sender the gesture recognizer that was triggered
 call the delegate method to segue to the profile page
 */
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate didTapUser:self.post.author];
}
/**
 Triggered when the user taps the like button and updates the user profiles accordingly by
 calling a helper method
 @param[in] sender the UIbutton that was pressed

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
- (IBAction)didTapComment:(id)sender {
    [self.delegate didTapComment:self.post];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
