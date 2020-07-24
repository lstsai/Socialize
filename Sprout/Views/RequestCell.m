//
//  RequestCell.m
//  Sprout
//
//  Created by laurentsai on 7/23/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "RequestCell.h"
#import "Helper.h"
#import "Constants.h"
@implementation RequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.acceptButton.alpha=SHOW_ALPHA;
    self.deleteButton.alpha=SHOW_ALPHA;
    self.statusLabel.alpha=HIDE_ALPHA;
}
-(void) loadData{
    self.nameLabel.text=self.requestUser.username;
    self.profileImage.file=self.requestUser[@"profilePic"];
    [self.profileImage loadInBackground];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
}

-(void) showStatus:(NSString*) message{
    self.acceptButton.alpha=HIDE_ALPHA;
    self.deleteButton.alpha=HIDE_ALPHA;
    self.statusLabel.text=message;
    self.statusLabel.alpha=SHOW_ALPHA;
}
- (IBAction)didTapAccept:(id)sender {
    
    [self showStatus:@"Accepted"];
       [Helper removeRequest:PFUser.currentUser forUser:self.requestUser];
       [Helper addFriend:PFUser.currentUser toFriend:self.requestUser];
       [Helper addFriend:self.requestUser toFriend:PFUser.currentUser];
}
- (IBAction)didTapDelete:(id)sender {

    [self showStatus:@"Declined"];
    [Helper removeRequest:PFUser.currentUser forUser:self.requestUser];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
