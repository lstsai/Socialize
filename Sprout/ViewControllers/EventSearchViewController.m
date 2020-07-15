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

@interface EventSearchViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation EventSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    EventCell *orgCell=[[EventCell alloc] init];
    return orgCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}
-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
           return;
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     
    PFQuery *eventsQuery=[PFQuery queryWithClassName:@"Event"];
    [eventsQuery setLimit:RESULTS_SIZE];
    [eventsQuery includeKey:@"author"];
    [eventsQuery whereKey:@"name" containsString:self.searchText];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
