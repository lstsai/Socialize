//
//  SearchViewController.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 View controller where the user searches for organizations, events, and users.
 */
#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "Constants.h"
#import "InfiniteScrollActivityView.h"
#import "LocationManager.h"
#import "EventSearchViewController.h"
#import "OrgSearchViewController.h"
#import "PeopleSearchViewController.h"
#import "CreateViewController.h"
@import MapKit;
NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
//container view views for each of the search types
@property (weak, nonatomic) IBOutlet UIView *eventsView;
@property (weak, nonatomic) IBOutlet UIView *orgsView;
@property (weak, nonatomic) IBOutlet UIView *peopleView;
//the view controller associated with the container views
@property (weak, nonatomic) EventSearchViewController *eventsVC;
@property (weak, nonatomic) OrgSearchViewController *orgsVC;
@property (weak, nonatomic) PeopleSearchViewController *peopleVC;
@property (strong, nonatomic) LocationManager *locManager;
@property (nonatomic) CLLocationCoordinate2D locationCoord;
@property (strong, nonatomic) NSString* citySearch;
@property (strong, nonatomic) NSString* stateSearch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchControl;

-(void) setupSegmentControl;
-(void) fetchResults:(UIRefreshControl * _Nullable)refreshControl;

@end

NS_ASSUME_NONNULL_END
