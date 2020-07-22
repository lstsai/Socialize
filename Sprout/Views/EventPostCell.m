//
//  EventPostCell.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventPostCell.h"
#import "DateTools.h"
#import "Constants.h"
@import Parse;
@implementation EventPostCell

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
    
    self.event=(Event *)self.post.relatedObject;
    self.eventImage.file=self.event.image;
    [self.eventImage loadInBackground];
    self.eventNameLabel.text=self.event.name;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"E, d MMM yyyy h:mm a"];
    self.eventDateTime.text = [dateFormat stringFromDate:self.event.startTime];
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
}
-(void) getLikes{
    PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
    [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    [friendAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* userAccess=object;
        if(userAccess[@"friendEvents"][self.event.objectId])
        {
            self.event.numFriendsLike=((NSArray*)userAccess[@"friendEvents"][self.event.objectId]).count;
            self.numLikeLabel.text=[NSString stringWithFormat:@"%lu friends have liked this", self.event.numFriendsLike];
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
