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
}
@end
