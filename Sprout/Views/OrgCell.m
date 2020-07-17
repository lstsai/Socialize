//
//  OrgCell.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgCell.h"

@implementation OrgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor]; // very important
    self.layer.masksToBounds = false;
    self.layer.shadowOpacity = 0.23;
    self.layer.shadowRadius = 4;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    // add corner radius on `contentView`
    self.contentView.backgroundColor =[UIColor whiteColor];
    self.contentView.layer.cornerRadius = 8;
}
-(void) loadData{
    self.nameLabel.text=self.org.name;
    self.tagLineLabel.text=self.org.tagLine;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
