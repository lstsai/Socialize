//
//  OrgCollectionCell.h
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
Collection view cells for the organizations that display on the Profile page
*/
#import <UIKit/UIKit.h>
#import "Organization.h"
#import "UIImageView+AFNetworking.h"
#import "ClaimedOrganization.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface OrgCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *orgImage;
@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
@property (strong, nonatomic) ClaimedOrganization *_Nullable claimedOrg;

-(void) loadOrgCell:(Organization*)org;
-(void) checkClaimed:(Organization*)org;
@end

NS_ASSUME_NONNULL_END
