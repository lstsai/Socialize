//
//  EventGroupCell.h
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Cell representing a post in the event group page
 */
#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@protocol EventGroupCellDelegate
- (void)didTapUser: (PFUser *)user;
- (void)didTapComment: (Post *)post;
@end

@interface EventGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (strong, nonatomic) Post* post;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet PFImageView *postImage;
@property (nonatomic, weak) id<EventGroupCellDelegate> delegate;

-(void) didTapUserProfile:(UITapGestureRecognizer*) sender;
-(void) loadDetails;
@end

NS_ASSUME_NONNULL_END
