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
#import "AppDelegate.h"
#import "OrgCell.h"
#import "Helper.h"
#import "Post.h"
#import "UIScrollView+EmptyDataSet.h"
@import ListPlaceholder;
@interface OrgSearchViewController ()<UITableViewDelegate, UITableViewDataSource, OrgCellDelegate, OrgDetailsViewControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@end

@implementation OrgSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     //Do any additional setup after loading the view.
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.pageNum=1;
    self.organizations=[[NSMutableArray alloc]init];
    [self setupLoadingIndicators];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [UIView new];
}
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

-(void) getOrgs:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
        return;
    if(![refreshControl isKindOfClass:[UIRefreshControl class]] &&self.organizations.count==0)
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    else
        [self.tableView showLoader];
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":self.searchText, @"rated":@"TRUE", @"state": self.stateSearch, @"city": self.citySearch, @"pageSize":@(RESULTS_SIZE)};
     [[APIManager shared] getOrganizationsWithCompletion:params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
         if(error)
            [AppDelegate displayAlert:@"Error getting organizations" withMessage:error.localizedDescription on:self];
         self.organizations=[organizations mutableCopy];
         [self.tableView reloadData];
         
         if([refreshControl isKindOfClass:[UIRefreshControl class]])
             [refreshControl endRefreshing];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self.tableView hideLoader];
     }];
}
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
-(void) loadMoreResults{
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":self.searchText, @"rated":@"TRUE", @"state": self.stateSearch, @"city": self.citySearch, @"pageNum": @(self.pageNum), @"pageSize":@(RESULTS_SIZE)};
    [[APIManager shared] getOrganizationsWithCompletion:params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
        if(error)
        {
            [AppDelegate displayAlert:@"Error getting organizations" withMessage:error.localizedDescription on:self];
        }
        else{
            [self.organizations addObjectsFromArray:organizations];
            [self.tableView reloadData];
            [self.loadingMoreView stopAnimating];
        }
        self.isMoreDataLoading=NO;

    }];
}

- (void)didLikeOrg:(Organization*)likedOrg{
    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];
    [likedOrgs addObject:likedOrg.ein];
    [self performSelectorInBackground:@selector(addOrgToFriendsList:) withObject:likedOrg];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser saveInBackground];
    [Post createPost:nil withDescription:@"Liked an Organization" withEvent:nil withOrg:likedOrg withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error)
            [AppDelegate displayAlert:@"Error Posting" withMessage:error.localizedDescription on:self];
    }];
}
- (void)didUnlikeOrg:(Organization*)unlikedOrg{
    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];

    [likedOrgs removeObject:unlikedOrg.ein];
    [self performSelectorInBackground:@selector(deleteOrgFromFriendsList:) withObject:unlikedOrg];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser saveInBackground];
}

-(void) addOrgToFriendsList:(Organization*)likedOrg{
    /*
     In order for Parse to actually save an object. It has to detect a significant enough change
     in that object. Just adding/removing one object from an array is not enough for Parse to
     save the object. Parse also does not allow users to modify attributes of other users. I added
     a UserAccess pointer to each user, so that other are not directly modifying to user. The UserAccess
     class contains an array of friend and dictionaries containing orgs/events that are liked by friends.
     */
    
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        for(PFObject* friend in friends)//get the array of friends for current user
        {
            //if the friend alreay has other friends that like this org
            PFObject * faAcess=friend[@"friendAccessible"];
            if(faAcess[@"friendOrgs"][likedOrg.ein])
            {
                //add own username to that list of friends
                NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
                
                NSMutableArray* list= [friendOrgs[likedOrg.ein] mutableCopy];
                [list addObject:PFUser.currentUser.username];
                
                friendOrgs[likedOrg.ein]=list;
                faAcess[@"friendOrgs"]= friendOrgs;
            }
            else
            {
                //create that array for the ein and add self as the person who liked it
                NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
                friendOrgs[likedOrg.ein]=@[PFUser.currentUser.username];
                faAcess[@"friendOrgs"]= friendOrgs;
            }
            //save each friend
            [faAcess saveInBackground];
        }
    }];
}
-(void) deleteOrgFromFriendsList:(Organization*)unlikedOrg{
    
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        for(PFObject* friend in friends)//get the array of friends for current user
        {
            PFObject * faAcess=friend[@"friendAccessible"];
            if(faAcess[@"friendOrgs"][unlikedOrg.ein])
            {
                //add own username to that list of friends
                NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
                
                NSMutableArray* list= [friendOrgs[unlikedOrg.ein] mutableCopy];
                [list removeObject:PFUser.currentUser.username];
                
                friendOrgs[unlikedOrg.ein]=list;
                faAcess[@"friendOrgs"]= friendOrgs;
            }
            //save each friend
            [faAcess saveInBackground];
        }
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
        orgVC.org=self.organizations[tappedIndex.item];
        orgVC.delegate=self;
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrgCell *orgCell= [tableView dequeueReusableCellWithIdentifier:@"OrgCell" forIndexPath:indexPath];
    orgCell.org=self.organizations[indexPath.item];
    orgCell.delegate=self;
    [orgCell loadData];
    return orgCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.organizations.count;;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptySprout"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Organizations to Show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
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
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.organizations.count==0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CELL_TOP_OFFSET, 0);
    cell.contentView.alpha = SHOW_ALPHA*0.3;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        cell.layer.transform =CATransform3DIdentity;
        cell.contentView.alpha = SHOW_ALPHA;
    }];
}

@end
