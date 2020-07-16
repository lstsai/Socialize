//
//  ProfileViewController.h
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organization.h"
#import "Event.h"
#import "APIManager.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendCount;
@property (weak, nonatomic) IBOutlet UILabel *orgCount;
@property (weak, nonatomic) IBOutlet UILabel *eventCount;
@property (weak, nonatomic) IBOutlet UICollectionView *orgCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *eventCollectionView;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSArray *likedOrgs;
@property (strong, nonatomic) NSArray *likedEvents;


-(void)getLikedOrgInfo;
-(void)getLikedEventInfo;
-(void)loadProfile;

@end

NS_ASSUME_NONNULL_END
