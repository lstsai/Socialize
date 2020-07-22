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
-(void) loadData{
    self.nameLabel.text=self.post.author.username;
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.file=self.post.author[@"profilePic"];
    [self.profileImage loadInBackground];
    self.postDescriptionLabel.text=self.post.postDescription;
    self.timeLabel.text=[self.post.createdAt shortTimeAgoSinceNow];
    
    self.org= [Organization orgWithDictionary:(NSDictionary*) self.post.org];
    
    [self.orgImage setImageWithURL:self.org.imageURL];
 
    self.orgNameLabel.text=self.org.name;
    self.locationLabel.text=[self.org.location.city stringByAppendingFormat:@", %@", self.org.location.state];
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
}
-(void) getLikes{
    PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
    [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    [friendAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* userAccess=object;
        if(userAccess[@"friendOrgs"][self.org.ein])
        {
            self.org.numFriendsLike=((NSArray*)userAccess[@"friendOrgs"][self.org.ein]).count;
            self.numLikeLabel.text=[NSString stringWithFormat:@"%lu friends have liked this", self.org.numFriendsLike];
            self.numLikeLabel.alpha=SHOW_ALPHA;
        }
        else
        {
            self.numLikeLabel.alpha=HIDE_ALPHA;
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
