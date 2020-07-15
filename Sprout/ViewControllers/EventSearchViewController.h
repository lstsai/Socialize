//
//  EventSearchViewController.h
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import "InfiniteScrollActivityView.h"
NS_ASSUME_NONNULL_BEGIN

@interface EventSearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* events;
@property (strong, nonatomic) NSString* searchText;
@property (strong, nonatomic) NSString* stateSearch;
@property (strong, nonatomic) NSString* citySearch;
@property (strong, nonatomic) LocationManager *locManager;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;

-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl;
-(void) loadMoreResults;
-(void) setupLoadingIndicators;
@end

NS_ASSUME_NONNULL_END
