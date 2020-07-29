//
//  CommentCell.m
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "CommentCell.h"
#import "DateTools.h"
@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void) loadComment{
    //NSLog(@"Load comment %@", self.comment);
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.layer.cornerRadius=self.profileImage.bounds.size.width/2;
    UIGestureRecognizer *profileTapGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage setUserInteractionEnabled:YES];
    [self.profileImage addGestureRecognizer:profileTapGesture];
    if(self.comment.author[@"profilePicture"])
    {
        self.profileImage.file=self.comment.author[@"profilePicture"];
        [self.profileImage loadInBackground];
    }
    self.commentText.text=self.comment.commentText;
    self.timeLabel.text=[self.comment.createdAt shortTimeAgoSinceNow];
    self.nameLabel.text=self.comment.author.username;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
