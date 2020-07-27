//
//  OrgPostCell.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Table view cell that represents a post about an organization on the home timeline
 */
#import <UIKit/UIKit.h>
#import "Organization.h"
#import "Post.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@protocol OrgPostCellDelegate
- (void)didTapUser: (PFUser *)user;
@end

@interface OrgPostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgTaglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLikeLabel;
@property (weak, nonatomic) IBOutlet UIView *orgContainer;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIImageView *orgImage;
@property (strong, nonatomic) Organization* org;
@property (strong, nonatomic) Post* post;
@property (nonatomic, weak) id<OrgPostCellDelegate> delegate;


-(void)loadData;
-(void) getLikes;
-(void) setShadow;
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender;
@end

NS_ASSUME_NONNULL_END
