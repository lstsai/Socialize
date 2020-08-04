//
//  DMCell.m
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "DMCell.h"
#import "DateTools.h"
#import "Constants.h"
@implementation DMCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void) loadData{
    self.profileImage.image=nil;
    self.messageLabel.text=nil;
    //add a tap gesture recognizer so user can tap on the profile image and be taken to the profile page
    UIGestureRecognizer *profileTapGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage setUserInteractionEnabled:YES];
    [self.profileImage addGestureRecognizer:profileTapGesture];
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.layer.cornerRadius=self.profileImage.bounds.size.width/2;
    
    self.profileImage.file=self.user[@"profilePic"];
    [self.profileImage loadInBackground];
    if(self.unread)
        [self markUnread];
    else
        [self markRead];
    self.messageLabel.text=self.latestMessage.messageText;
    self.timeLabel.text=[self.latestMessage.createdAt shortTimeAgoSinceNow];
    self.nameLabel.text=self.user.username;
}
/**
 Change message label to indicate readMessage
 */
-(void) markRead{
    [self.messageLabel setFont:[UIFont systemFontOfSize:EMPTY_MESSAGE_FONT_SIZE]];
}
/**
Change message label to indicate unreadMessage
*/
-(void) markUnread{
    [self.messageLabel setFont:[UIFont boldSystemFontOfSize:EMPTY_MESSAGE_FONT_SIZE]];
}
/**
 Triggered when the user taps on the user profile image
 @param[in] sender the gesture recognizer that was triggered
 call the delegate method to segue to the profile page
 */
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate didTapUser:self.user];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
