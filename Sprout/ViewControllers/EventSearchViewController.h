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
#import "Event.h"
NS_ASSUME_NONNULL_BEGIN

@interface EventSearchViewController : UIViewController
@property (strong, nonatomic) NSMutableArray* events;
@property (strong, nonatomic) NSString* searchText;
@property (strong, nonatomic) NSString* stateSearch;
@property (strong, nonatomic) NSString* citySearch;
@property (strong, nonatomic) LocationManager *locManager;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl;
-(void) loadMoreResults;
-(void) setupLoadingIndicators;
-(void) addEventToFriendsList:(Event*)likedEvent;
-(void) deleteEventFromFriendsList:(Event*)unlikedEvent;


@end

NS_ASSUME_NONNULL_END
