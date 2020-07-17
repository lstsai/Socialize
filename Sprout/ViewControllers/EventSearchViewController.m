//
//  EventSearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventSearchViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "EventCell.h"
#import "EventDetailsViewController.h"
#import "AppDelegate.h"
@interface EventSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation EventSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    [self setupLoadingIndicators];
}
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getEvents:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.collectionView insertSubview:refreshControl atIndex:0];//add into the storyboard

    CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.collectionView addSubview:self.loadingMoreView];

    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.collectionView.contentInset = insets;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EventVerticalCell *eventCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"EventVerticalCell" forIndexPath:indexPath];
    eventCell.event = self.events[indexPath.item];
    [eventCell loadData];
    return eventCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.events.count;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

    cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0);
    cell.contentView.alpha = 0.3;

    [UIView animateWithDuration:0.75 animations:^{
        cell.layer.transform =CATransform3DIdentity;
        cell.contentView.alpha = 1;
    }];
}

-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
        return;
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *eventsNameQuery=[PFQuery queryWithClassName:@"Event"];
    
    [eventsNameQuery whereKey:@"name" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchText]];
    
    PFQuery *eventsDetailsQuery=[PFQuery queryWithClassName:@"Event"];
    [eventsDetailsQuery whereKey:@"details" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchText]];
    
    PFQuery *eventsQuery=[PFQuery orQueryWithSubqueries:@[eventsNameQuery,eventsDetailsQuery]];
    
    if(![self.stateSearch isEqualToString:@""] || ![self.citySearch isEqualToString:@""])
    {
        [eventsQuery whereKey:@"streetAddress" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.citySearch]];
        [eventsQuery whereKey:@"streetAddress" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.stateSearch]];
    }
    [eventsQuery includeKey:@"author"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [AppDelegate displayAlert:@"Error getting events" withMessage:error.localizedDescription on:self];
        else
        {
            self.events=[objects mutableCopy];
            [self.collectionView reloadData];
        }
        if([refreshControl isKindOfClass:[UIRefreshControl class]])
            [refreshControl endRefreshing];
        else
            [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading)
    {
        int scrollContentHeight=self.collectionView.contentSize.height;
        int scrollOffsetThreshold = scrollContentHeight - self.collectionView.bounds.size.height;
        
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.collectionView.isDragging)
        {
            self.isMoreDataLoading=YES;
            self.pageNum++;
            CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            self.loadingMoreView.frame = frame;
            [self.loadingMoreView startAnimating];
            [self loadMoreResults];
        }
        
    }
}
-(void) loadMoreResults{
    [self.loadingMoreView stopAnimating];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"detailSegue"])
    {
        EventDetailsViewController *eventVC=segue.destinationViewController;
        UICollectionViewCell *tappedCell= sender;
        NSIndexPath *tappedIndex= [self.collectionView indexPathForCell:tappedCell];
        eventVC.event=self.events[tappedIndex.row];
        [self.collectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
}

@end
