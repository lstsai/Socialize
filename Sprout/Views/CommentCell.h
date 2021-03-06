//
//  CommentCell.h
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Cell representing a comment on a post
 */
#import <UIKit/UIKit.h>
#import "Comment.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN
@protocol CommentCellDelegate
- (void)didTapUser: (PFUser *)user;
@end
@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentText;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) Comment* comment;
@property (nonatomic, weak) id<CommentCellDelegate> delegate;

- (void) loadComment;
-(void) didTapUserProfile:(UITapGestureRecognizer*) sender;
@end

NS_ASSUME_NONNULL_END
