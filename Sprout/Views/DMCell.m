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
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.layer.cornerRadius=self.profileImage.bounds.size.width/2;
    
    self.profileImage.file=self.user[@"profilePic"];
    [self.profileImage loadInBackground];
    if(self.unread)
        [self.messageLabel setFont:[UIFont boldSystemFontOfSize:EMPTY_MESSAGE_FONT_SIZE]];
    else
        [self.messageLabel setFont:[UIFont systemFontOfSize:EMPTY_MESSAGE_FONT_SIZE]];
    self.messageLabel.text=self.latestMessage.messageText;
    self.timeLabel.text=[self.latestMessage.createdAt shortTimeAgoSinceNow];
    self.nameLabel.text=self.user.username;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
