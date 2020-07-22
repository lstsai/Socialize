//
//  EventPostCell.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Event.h"

@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface EventPostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (strong, nonnull) Post* post;
@property (strong, nonnull) Event* event;

@property (weak, nonatomic) IBOutlet PFImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateTime;
@property (weak, nonatomic) IBOutlet UILabel *numLikeLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
-(void) loadData;
@end

NS_ASSUME_NONNULL_END
