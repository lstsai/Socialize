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
    [self setShadow];

    self.orgNameLabel.text=self.org.name;
    self.orgTaglineLabel.text=self.org.tagLine;
    self.locationLabel.text=[self.org.location.city stringByAppendingFormat:@", %@", self.org.location.state];
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
}
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
    self.orgContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.orgContainer.bounds cornerRadius:self.orgContainer.layer.cornerRadius].CGPath;
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
