//
//  OrgCollectionCell.m
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgCollectionCell.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"
@implementation OrgCollectionCell
/**
Loads the cell data from the Organization
 @param[in] org the organization that this cell  represents
*/
-(void) loadOrgCell:(Organization*)org{
    //clears the event image, makes an API call to get the logo of the organization
    self.orgImage.image=nil;
    [[APIManager shared] getOrgImage:org.name completion:^(NSURL * _Nonnull orgImage, NSError * _Nonnull error) {
        if(orgImage)
        {
            org.imageURL=orgImage;
            [self.orgImage setImageWithURL:org.imageURL];
        }
    }];
    
    self.orgNameLabel.text=org.name;
    //rounded corners for the cell
    self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;
    //shadow for the cell
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET);
    self.layer.shadowRadius = SHADOW_RADIUS;
    self.layer.shadowOpacity = SHADOW_OPACITY;
    self.layer.masksToBounds = NO;
}
@end
