//
//  PeopleSearchViewController.h
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonCell.h"
#import <Parse/Parse.h>
#import "InfiniteScrollActivityView.h"
NS_ASSUME_NONNULL_BEGIN

@interface PeopleSearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString* searchText;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;
@property (strong, nonatomic) NSMutableArray *people;
@property (nonatomic) BOOL isMoreDataLoading;
@property (nonatomic) int resultNum;


-(void) getPeople:( UIRefreshControl * _Nullable )refreshControl;
-(void) setupLoadingIndicators;
-(void) setUpLayout;
@end

NS_ASSUME_NONNULL_END
