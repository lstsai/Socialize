//
//  FriendCell.h
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Cell representing each friend the user has
 */
#import <UIKit/UIKit.h>
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgsLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventsLabel;
@property (strong, nonatomic) PFUser* user;

-(void) loadDetails;
@end

NS_ASSUME_NONNULL_END
