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
/**
 Loads the views for the cell
 */
-(void) loadData{
    self.nameLabel.text=self.requestUser.username;
    self.profileImage.file=self.requestUser[@"profilePic"];
    [self.profileImage loadInBackground];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
}
/**
Shows the status message of the request after being accepted/declined. also hides the accept and delete buttons
 @param[in] message the message to be shown as the status
 */
-(void) showStatus:(NSString*) message{
    self.acceptButton.alpha=HIDE_ALPHA;
    self.deleteButton.alpha=HIDE_ALPHA;
    self.statusLabel.text=message;
    self.statusLabel.alpha=SHOW_ALPHA;
}
/**
Triggered when the user presses the 'accept' button. Calls the showStatus: method to show 'Accepted' status
 @param[in] sender the UIbuttont that is pressed
 */
- (IBAction)didTapAccept:(id)sender {
    
    [self showStatus:@"Accepted"];
       [Helper removeRequest:PFUser.currentUser forUser:self.requestUser];
       [Helper addFriend:PFUser.currentUser toFriend:self.requestUser];
       [Helper addFriend:self.requestUser toFriend:PFUser.currentUser];
}
/**
Triggered when the user presses the 'delete' button. Calls the showStatus: method to show 'Declined' status
 @param[in] sender the UIbuttont that is pressed
 */
- (IBAction)didTapDelete:(id)sender {

    [self showStatus:@"Declined"];
    [Helper removeRequest:PFUser.currentUser forUser:self.requestUser];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
