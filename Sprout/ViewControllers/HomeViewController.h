//
//  HomeViewController.h
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfiniteScrollActivityView.h"
NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *posts;
@property (nonatomic) int pageNum;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;
@property (nonatomic) BOOL isMoreDataLoading;
-(void) getPosts:( UIRefreshControl * _Nullable )refreshControl;
-(void) setupLoadingIndicators;
@end

NS_ASSUME_NONNULL_END
