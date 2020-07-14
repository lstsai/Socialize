//
//  SearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "SearchViewController.h"
#import "OrgCell.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "OrgDetailsViewController.h"
@interface SearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, UIScrollViewDelegate>

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.searchBar.delegate=self;
    self.organizations=[[NSMutableArray alloc]init];
    [self setupLoadingIndicators];
    [self.tableView reloadData];
    
    self.locManager=[LocationManager sharedInstance];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OrgCell *orgCell= [tableView dequeueReusableCellWithIdentifier:@"OrgCell"];
    orgCell.org=self.organizations[indexPath.row];
    [orgCell loadData];
    return orgCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.organizations.count;
}

-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(fetchResults:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.tableView insertSubview:refreshControl atIndex:0];//add into the storyboard
    
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
}

- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(error)
            NSLog(@"Error Logging out: %@", error.description);
        else
            NSLog(@"Success Logging out");
    }];
    //go back to login
    SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.pageNum=1;
    if (self.searchTimer != nil) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }

    // reschedule the search: in 1.0 second, call the searchForKeyword: method on the new textfield content
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval: SEARCH_DELAY
                                                        target: self
                                                      selector: @selector(fetchResults:)
                                                      userInfo: nil
                                                       repeats: NO];
    self.pageNum=1;
}
- (IBAction)didChangeLocation:(id)sender {
    self.pageNum=1;
    [self fetchResults:nil];
}
-(void) fetchResults:( UIRefreshControl * _Nullable )refreshControl{
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString* stateSearch, *citySearch;
    if([self.stateField.text isEqualToString:@""] && [self.cityField.text  isEqualToString:@""])
        stateSearch=self.locManager.currentPlacemark.administrativeArea;//the state
        //citySearch=self.locManager.currentPlacemark.locality;
    else
        stateSearch=self.stateField.text;
    
    citySearch=self.cityField.text;
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":self.searchBar.text, @"rated":@"TRUE", @"state": stateSearch, @"city": citySearch, @"pageNum": @(self.pageNum), @"pageSize":@(RESULTS_SIZE)};
    
    NSLog(@"%@   %@",stateSearch, citySearch);
   
    [[APIManager shared] getOrganizationsWithCompletion:params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
        if(error)
        {
            NSLog(@"Error getting organizations: %@", error.localizedDescription);
        }
        else{
            self.organizations=[organizations mutableCopy];
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
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":self.searchBar.text, @"rated":@"TRUE", @"state": self.stateField.text, @"city": self.cityField.text, @"pageNum": @(self.pageNum), @"pageSize":@(RESULTS_SIZE)};
    [[APIManager shared] getOrganizationsWithCompletion:params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
        if(error)
        {
            NSLog(@"Error getting organizations: %@", error.localizedDescription);
        }
        else{
            [self.organizations addObjectsFromArray:organizations];
            [self.tableView reloadData];
            [self.loadingMoreView stopAnimating];
        }
        self.isMoreDataLoading=NO;

    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"detailSegue"])
    {
        OrgDetailsViewController *orgVC=segue.destinationViewController;
        UITableViewCell *tappedCell= sender;
        NSIndexPath *tappedIndex= [self.tableView indexPathForCell:tappedCell];
        orgVC.org=self.organizations[tappedIndex.row];
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
}


@end
