//
//  OrgSearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgSearchViewController.h"
#import "MBProgressHUD.h"
#import "APIManager.h"
#import "OrgDetailsViewController.h"
#import "OrgCell.h"
#import "Helper.h"
#import "Post.h"
#import "UIScrollView+EmptyDataSet.h"
#import "LocationManager.h"
#import "MapViewController.h"
@interface OrgSearchViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@end

@implementation OrgSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     //Do any additional setup after loading the view.
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    self.pageNum=1;
    self.organizations=[[NSMutableArray alloc]init];
    [self setupLoadingIndicators];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [UIView new];
    self.params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"rated":@"TRUE", @"pageSize":@(RESULTS_SIZE)}.mutableCopy;
}
/**
 Set up the refresh control and infinite scrolling indicators for the table view
 */
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getOrgs:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.tableView insertSubview:refreshControl atIndex:0];//add into the storyboard

    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];

    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
}
/**
 Makes the API call to get the organization based on the search. If not enough results were returned
 for the given location search, will ask the user if they would like to search further away.
 @param[in] refreshControl the activity indicator that is animating if there is one
 */
-(void) getOrgs:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
    {
        if([refreshControl isKindOfClass:[UIRefreshControl class]])
            [refreshControl endRefreshing];
        return;
    }
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.pageNum=1;//reset the page number for the results
    //upadte the parameter values of the search
    [self.params setValue:self.searchText forKey:@"search"];
    [self.params setValue:self.stateSearch forKey:@"state"];
    [self.params setValue:self.citySearch forKey:@"city"];
    [self.params setValue:@(self.pageNum) forKey:@"pageNum"];

    [[APIManager shared] getOrganizationsWithCompletion:self.params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
         if(error)
         {
             [Helper displayAlert:@"Error getting organizations" withMessage:error.localizedDescription on:self];
             self.organizations=@[].mutableCopy;
         }
         else{
             self.organizations=[organizations mutableCopy];
             [self.tableView reloadData];
             //if not enough results were returned, asked the user if they want to do another search further
             if(self.organizations.count<MIN_RESULT_THRESHOLD){
                 UIAlertController* alert= [UIAlertController alertControllerWithTitle:@"Few Results in this Area" message:@"Would you like to search cities further away?" preferredStyle:(UIAlertControllerStyleAlert)];
                 UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     [self getFurtherOrgs];
                 }];
                 UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 }];
                 [alert addAction:noAction];
                 [alert addAction:yesAction];
                 [self presentViewController:alert animated:YES completion:nil];
             }
         }
         if([refreshControl isKindOfClass:[UIRefreshControl class]])
             [refreshControl endRefreshing];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
    
    
}
/**
 Makes the API call to get nearby cities and fetch the organizations in those cities.
 */
-(void)getFurtherOrgs{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[APIManager shared] getOrgsNearLocation:self.locationCoord withSearch:self.searchText withCompletion:^(NSArray * _Nonnull orgs, NSError * _Nonnull error) {
        if(error)
            NSLog(@"%@", error.localizedDescription);
        else
            self.organizations=orgs.mutableCopy;
        [self.tableView reloadData];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
/**
Triggered when the user scrolls on the table view. Determines if the program should load more data
 depending on how far the user has scrolled and if more data is already loading. Calls the getPosts method
 if more organizations are needed. Update page number to retrieve new orgs
@param[in] scrollView table view that is being scrolled
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading && self.organizations.count!=0)
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
/**
Makes the API call to get more organizations based on the search.
*/
-(void) loadMoreResults{
    [self.params setValue:@(self.pageNum) forKey:@"pageNum"];
    [[APIManager shared] getOrganizationsWithCompletion:self.params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
        if(error && ![error.localizedDescription isEqualToString:@"Request failed: not found (404)"])
        {
            [Helper displayAlert:@"Error getting organizations" withMessage:error.localizedDescription on:self];
            self.organizations=@[].mutableCopy;
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
    if([segue.identifier isEqualToString:@"detailSegue"])//takes the user to the organizations's details page
    {
        OrgDetailsViewController *orgVC=segue.destinationViewController;
        UITableViewCell *tappedCell= sender;
        NSIndexPath *tappedIndex= [self.tableView indexPathForCell:tappedCell];
        orgVC.org=self.organizations[tappedIndex.item];
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
    else if([segue.identifier isEqualToString:@"mapSegue"])//takes user to the map page
    {
        MapViewController *mapVC= segue.destinationViewController;
        mapVC.objects=self.organizations;
    }
}
/**
Table view delegate method. returns a cell to be shown at the index path
@param[in] tableView the table that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrgCell *orgCell= [tableView dequeueReusableCellWithIdentifier:@"OrgCell" forIndexPath:indexPath];
    orgCell.org=self.organizations[indexPath.item];
    [orgCell loadData];
    return orgCell;
}
/**
Table view delegate method. returns the number of sections that the table has. This table only has
 one section so it always returns the total number of organizations
@param[in] tableView the table that is calling this method
@param[in] section the section in question
@return the number of organizations
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.organizations.count;;
}
/**
Empty table view delegate method. Returns the image to be displayed when there are no organizations
@param[in] scrollView the table view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptySprout"];
}
/**
Empty table view delegate method. Returns the title to be displayed when there are no organizations
@param[in] scrollView the table view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Organizations to Show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty table view delegate method. Returns the message to be displayed when there are no organizations
@param[in] scrollView the table view that is empty
@return the message to be shown
*/
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Search for more organizations to display";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:EMPTY_MESSAGE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty table view delegate method. Returns if the empty view should be shown
@param[in] scrollView the table view that is empty
@return if the empty view shouls be shown
 YES: if there are no orgs
 NO: there are orgs
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.organizations.count==0;
}
/**
Table view delegate method. Configures the animations for the cell that is about to be shown.
 Shifts the cell's starting top position lower and animates it so that the it shifts up when scrolled.
 Also makes gradually makes the cell more opaque
@param[in] tableView the table view that is empty
@param[in] cell the cell that is about to be shown
@param[in] indexPath the index path of the cell
*/
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CELL_TOP_OFFSET, 0);
    cell.contentView.alpha = SHOW_ALPHA*0.3;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        cell.layer.transform =CATransform3DIdentity;
        cell.contentView.alpha = SHOW_ALPHA;
    }];
}

@end
