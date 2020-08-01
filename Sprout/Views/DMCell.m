//
//  DMCell.m
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "DMCell.h"
#import "DateTools.h"
@implementation DMCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void) loadData{
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.layer.cornerRadius=self.profileImage.bounds.size.width/2;
    
    self.profileImage.file=self.user[@"profilePic"];
    [self.profileImage loadInBackground];
    
    self.messageLabel.text=self.latestMessage.messageText;
    self.timeLabel.text=[self.latestMessage.createdAt shortTimeAgoSinceNow];
    self.nameLabel.text=self.latestMessage.sender.username;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
