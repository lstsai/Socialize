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
