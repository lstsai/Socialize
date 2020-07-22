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
#import "Helper.h"
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
    
    self.likeButton.selected=[PFUser.currentUser[@"likedEvents"] containsObject:self.event.objectId];
    
    self.event=self.post.event;
    self.eventImage.file=self.event.image;
    [self.eventImage loadInBackground];
    self.eventImage.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.eventImage.layer.masksToBounds = YES;
    self.eventImage.clipsToBounds = YES;
    
    self.eventNameLabel.text=self.event.name;
    [self setShadow];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"E, d MMM yyyy h:mm a"];
    self.eventDateTime.text = [dateFormat stringFromDate:self.event.startTime];
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
}

-(void) setShadow{
    self.eventContainer.layer.cornerRadius = CELL_CORNER_RADIUS*2;
    self.eventContainer.layer.borderColor = [UIColor clearColor].CGColor;
    self.eventContainer.layer.masksToBounds = YES;
    self.eventContainer.clipsToBounds = YES;
    self.eventContainer.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.eventContainer.layer.shadowOffset = CGSizeMake(0, SHADOW_OFFSET/2);
    self.eventContainer.layer.shadowRadius = SHADOW_RADIUS;
    self.eventContainer.layer.shadowOpacity = SHADOW_OPACITY;
    self.eventContainer.layer.masksToBounds = NO;
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
- (IBAction)didTapLike:(id)sender {
    
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [Helper didLikeEvent:self.event senderVC:nil];

    }
    else{
        self.likeButton.selected=NO;
        [Helper didUnlikeEvent:self.event];

    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
