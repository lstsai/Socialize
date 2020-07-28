//
//  FriendsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 View controller that displays the selected user's friends
 */
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
NS_ASSUME_NONNULL_BEGIN

@interface FriendsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) PFUser *user;
-(void) getFriends;

@end

NS_ASSUME_NONNULL_END
