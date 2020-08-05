//
//  PersonCell.m
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "PersonCell.h"
#import "Constants.h"

@implementation PersonCell
/**
 Loads the cell's views to reflect the represented user
 */
-(void) loadData{
    
    self.nameLabel.text=self.user.username;
    self.bioLabel.text=self.user[@"bio"];
    if(self.user[@"backgroundPic"])//show background image if available
    {
        self.backgroundImage.file=self.user[@"backgroundPic"];
        [self.backgroundImage loadInBackground];
    }
    
    if(self.user[@"profilePic"])//show profile image if available
    {
        self.profileImage.file=self.user[@"profilePic"];
        [self.profileImage loadInBackground];
    }
    //circular profile image
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
    
    
    //rounded corners and shadows for the cell
    self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS*2;
    self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;

    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET);
    self.layer.shadowRadius = SHADOW_RADIUS;
    self.layer.shadowOpacity = SHADOW_OPACITY;
    self.layer.masksToBounds = NO;
}

@end
