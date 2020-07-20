//
//  OrgVerticalCell.m
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgVerticalCell.h"

@implementation OrgVerticalCell
-(void) loadData{
    self.nameLabel.text=self.org.name;
    self.tagLineLabel.text=self.org.tagLine;
    self.numLikeLabel.text=[NSString stringWithFormat:@"%lu", self.org.numFriendsLike];

    self.contentView.layer.cornerRadius = 20.0f;
    self.contentView.layer.borderWidth = 1.0f;
    self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;

    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOpacity = 0.5f;
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
}
@end
