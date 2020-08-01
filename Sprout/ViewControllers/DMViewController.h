//
//  DMViewController.h
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* messageThreads;
@property (strong, nonatomic) NSMutableArray* messageUsers;
@property (strong, nonatomic) NSArray* friends;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL isSearch;
-(void) getMessageThreads:(UIRefreshControl* _Nullable)refreshControl;
-(void) searchFriends;


@end

NS_ASSUME_NONNULL_END
