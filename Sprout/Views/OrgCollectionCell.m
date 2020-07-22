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
-(void) loadOrgCell:(Organization*)org{
    
    self.orgImage.image=nil;
    if(org.imageURL)//set image if available
    {
        [self.orgImage setImageWithURL:org.imageURL];
    }
    else{
        //fetch image if not available, set when complete
        [[APIManager shared] getOrgImage:org.name completion:^(NSURL * _Nonnull orgImage, NSError * _Nonnull error) {
            if(orgImage)
            {
                org.imageURL=orgImage;
                [self.orgImage setImageWithURL:org.imageURL];
            }
        }];
    }
    self.orgNameLabel.text=org.name;
    
    self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS;
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
