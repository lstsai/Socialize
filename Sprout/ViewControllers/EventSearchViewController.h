//
//  EventSearchViewController.h
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
Child view controller of the search view controller that displays the event search results
*/
#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import "Event.h"
NS_ASSUME_NONNULL_BEGIN

@interface EventSearchViewController : UIViewController
@property (strong, nonatomic) NSMutableArray* events;
@property (strong, nonatomic) NSString* searchText;
@property (nonatomic) CLLocationCoordinate2D locationCoord;
@property (strong, nonatomic) LocationManager *locManager;
@property (nonatomic) int pageNum;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl;
-(void) setupLoadingIndicators;
-(void) setupLayout;
@end

NS_ASSUME_NONNULL_END
