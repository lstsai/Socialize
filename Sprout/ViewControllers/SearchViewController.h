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
#import "LocationManager.h"
#import "EventSearchViewController.h"
#import "OrgSearchViewController.h"
#import "PeopleSearchViewController.h"
@import MapKit;
NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UIView *eventsView;
@property (weak, nonatomic) IBOutlet UIView *orgsView;
@property (weak, nonatomic) IBOutlet UIView *peopleView;
@property (weak, nonatomic) IBOutlet EventSearchViewController *eventsVC;
@property (weak, nonatomic) IBOutlet OrgSearchViewController *orgsVC;
@property (weak, nonatomic) IBOutlet PeopleSearchViewController *peopleVC;

@property (weak, nonatomic) IBOutlet UISegmentedControl *searchControl;
@property (strong, nonatomic) NSTimer * _Nullable searchTimer;

-(void) fetchResults:(UIRefreshControl * _Nullable)refreshControl;

@end

NS_ASSUME_NONNULL_END
