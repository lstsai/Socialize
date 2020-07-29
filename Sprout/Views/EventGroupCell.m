//
//  EventGroupCell.m
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventGroupCell.h"
#import "DateTools.h"
@implementation EventGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void) loadDetails{
    self.profileImage.file=self.post.author[@"profilePic"];
    [self.profileImage loadInBackground];
    self.profileImage.layer.cornerRadius=self.profileImage.frame.size.width/2;
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.clipsToBounds=YES;
    self.nameLabel.text=self.post.author.username;
    self.captionLabel.text=self.post.postDescription;
    self.timeLabel.text=[self.post.createdAt shortTimeAgoSinceNow];
    self.postImage.image=nil;
    if(self.post.image)
    {
        self.postImage.hidden=NO;
        self.postImage.file=self.post.image;
        [self.postImage loadInBackground];
    }
    else{
        self.postImage.hidden=YES;
    }
    self.tableView.hidden=YES;
    self.writeCommentView.hidden=YES;
}
- (IBAction)didTapComment:(id)sender {
    UIButton* commentButton=sender;
    if(!commentButton.selected){
        commentButton.selected=YES;
        self.tableView.hidden=NO;
        self.writeCommentView.hidden=NO;
    }
    if(commentButton.selected){
        commentButton.selected=NO;
        self.tableView.hidden=YES;
        self.writeCommentView.hidden=YES;
    }
    
}
- (IBAction)didTapPost:(id)sender {
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
