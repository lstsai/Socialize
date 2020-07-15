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
@interface EventSearchViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation EventSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self setupLoadingIndicators];
}
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getEvents:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.tableView insertSubview:refreshControl atIndex:0];//add into the storyboard

    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];

    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCell *eventCell=[tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    eventCell.event=self.events[indexPath.row];
    [eventCell loadData];
    return eventCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
           return;
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     
    PFQuery *eventsNameQuery=[PFQuery queryWithClassName:@"Event"];
    [eventsNameQuery whereKey:@"name" containsString:self.searchText];

    PFQuery *eventsDetailsQuery=[PFQuery queryWithClassName:@"Event"];
    [eventsDetailsQuery whereKey:@"details" containsString:self.searchText];

    PFQuery *eventsQuery=[PFQuery orQueryWithSubqueries:@[eventsNameQuery,eventsDetailsQuery]];

    if(![self.stateSearch isEqualToString:@""] || ![self.citySearch isEqualToString:@""])
    [eventsQuery whereKey:@"location" containedIn:@[self.citySearch, self.stateSearch]];
    [eventsQuery includeKey:@"author"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            NSLog(@"Error getting events %@", error.localizedDescription);
        else
        {
            self.events=[objects mutableCopy];
            [self.tableView reloadData];
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
           int scrollContentHeight=self.tableView.contentSize.height;
           int scrollOffsetThreshold = scrollContentHeight - self.tableView.bounds.size.height;
           
           if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging)
           {
               self.isMoreDataLoading=YES;
               self.pageNum++;
               CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
               self.loadingMoreView.frame = frame;
               [self.loadingMoreView startAnimating];
               [self loadMoreResults];
           }
           
       }
}
-(void) loadMoreResults{
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"detailSegue"])
       {
           EventDetailsViewController *eventVC=segue.destinationViewController;
           UITableViewCell *tappedCell= sender;
           NSIndexPath *tappedIndex= [self.tableView indexPathForCell:tappedCell];
           eventVC.event=self.events[tappedIndex.row];
           [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
       }
}


@end
