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
/**
 Loads the details for the cell according to the event
 */
-(void) loadDetails{
    self.profileImage.file=self.post.author[@"profilePic"];
    [self.profileImage loadInBackground];
    self.profileImage.layer.cornerRadius=self.profileImage.frame.size.width/2;
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.clipsToBounds=YES;
    UIGestureRecognizer *profileTapGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage setUserInteractionEnabled:YES];
    [self.profileImage addGestureRecognizer:profileTapGesture];
    
    self.nameLabel.text=self.post.author.username;
    self.captionLabel.text=self.post.postDescription;
    self.timeLabel.text=[self.post.createdAt shortTimeAgoSinceNow];
    if(self.post.image)
    {
        self.postImage.hidden=NO;
        self.postImage.file=self.post.image;
        [self.postImage loadInBackground];
    }
    else
    {
        self.postImage.hidden=YES;
    }
    [self.stackView layoutIfNeeded];
    [self.contentView layoutSubviews];

}
/**
 Triggered when the user taps the comment button on the cell. Shows the comment page
 by calling the delegate.
 @param[in] sender the button that was tapped
 */
- (IBAction)didTapComment:(id)sender {
    [self.delegate didTapComment:self.post];
}
/**
Triggered when the user taps the  profile pic on the cell. Shows the profile page
by calling the delegate.
@param[in] sender the button that was tapped
*/
-(void) didTapUserProfile:(UITapGestureRecognizer*) sender{
    [self.delegate didTapUser:self.post.author];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
