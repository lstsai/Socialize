//
//  FriendCell.m
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
 Load the information about this user
 */
-(void) loadDetails{
    self.nameLabel.text=self.user.username;
    self.bioLabel.text=self.user[@"bio"];
    self.orgsLabel.text=[NSString stringWithFormat:@"%lu Organizations", ((NSArray*)self.user[@"likedOrgs"]).count];
    self.eventsLabel.text=[NSString stringWithFormat:@"%lu Events", ((NSArray*)self.user[@"likedEvents"]).count];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.file=self.user[@"profilePic"];
    [self.profileImage loadInBackground];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
