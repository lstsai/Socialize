//
//  DMCell.h
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Cell representing a message thread with another user
 */
#import <UIKit/UIKit.h>
#import "Message.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface DMCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong,nonatomic) PFUser* user;
@property (strong, nonatomic) Message *_Nullable latestMessage;
@property (nonatomic) BOOL unread;

-(void) loadData;
-(void) markRead;
-(void) markUnread;

@end

NS_ASSUME_NONNULL_END
