//
//  EventPostCell.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
Table view cell that represents a post about an event on the home timeline
*/
#import <UIKit/UIKit.h>
#import "Post.h"
#import "Event.h"

@import Parse;
NS_ASSUME_NONNULL_BEGIN

@protocol EventPostCellDelegate
- (void)didTapUser: (PFUser *)user;
- (void)didTapComment: (Post *)post;
@end

@interface EventPostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (strong, nonnull) Post* post;
@property (strong, nonnull) Event* event;
@property (weak, nonatomic) IBOutlet UIView *eventContainer;
@property (weak, nonatomic) IBOutlet PFImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateTime;
@property (weak, nonatomic) IBOutlet UILabel *numLikeLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) id<EventPostCellDelegate> delegate;


-(void) loadData;
-(void) setShadow;
-(void) getLikes;
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender;

@end

NS_ASSUME_NONNULL_END
