//
//  OrgCell.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organization.h"
NS_ASSUME_NONNULL_BEGIN

@protocol OrgCellDelegate

- (void)didLikeOrg:(Organization*)likedOrg;
- (void)didUnlikeOrg:(Organization*)unlikedOrg;

@end

@interface OrgCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *orgImage;
@property (strong, nonatomic) Organization *org;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) id<OrgCellDelegate> delegate;


-(void) loadData;
-(void) getLikes;
@end

NS_ASSUME_NONNULL_END
