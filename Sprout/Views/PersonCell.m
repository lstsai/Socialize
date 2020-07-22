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
-(void) loadData{
    self.nameLabel.text=self.user.username;
    if(self.user[@"profilePic"])
    {
        self.profileImage.file=self.user[@"profilePic"];
        [self.profileImage loadInBackground];
    }
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
