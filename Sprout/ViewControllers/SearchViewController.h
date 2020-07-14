//
//  SearchViewController.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "Constants.h"
#import "InfiniteScrollActivityView.h"
@import MapKit;
NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (strong, nonatomic) NSMutableArray* organizations;
@property (strong, nonatomic) CLLocationManager *locManager;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;


-(void) fetchResults:(UIRefreshControl * _Nullable)refreshControl;
-(void) setupLoadingIndicators;
-(void) loadMoreResults;
@end

NS_ASSUME_NONNULL_END
