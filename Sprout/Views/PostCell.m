//
//  PostCell.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "PostCell.h"
#import "DateTools.h"
@import Parse;
@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void) loadData{
    self.nameLabel.text=self.post.author.username;
    self.profileImage.file=self.post.author[@"profilePic"];
    [self.profileImage loadInBackground];
    self.postDescriptionLabel.text=self.post.postDescription;
    self.timeLabel.text=[self.post.createdAt shortTimeAgoSinceNow];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
