//
//  OrgCollectionCell.m
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgCollectionCell.h"

@implementation OrgCollectionCell
-(void) loadOrgCell:(Organization*)org{
    [self.orgImage setImageWithURL:org.imageURL];
    self.orgNameLabel.text=org.name;
    
    self.contentView.layer.cornerRadius = 10.0f;
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
