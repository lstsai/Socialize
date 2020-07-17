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
#import "OrgVerticalCell.h"
@interface OrgSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@end

@implementation OrgSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     //Do any additional setup after loading the view.

    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;

    self.organizations=[[NSMutableArray alloc]init];
    [self setupLoadingIndicators];
    [self.collectionView reloadData];
}
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getOrgs:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.collectionView insertSubview:refreshControl atIndex:0];//add into the storyboard

    CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.collectionView addSubview:self.loadingMoreView];

    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.collectionView.contentInset = insets;
}

-(void) getOrgs:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
        return;
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":self.searchText, @"rated":@"TRUE", @"state": self.stateSearch, @"city": self.citySearch, @"pageSize":@(RESULTS_SIZE)};
     [[APIManager shared] getOrganizationsWithCompletion:params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
         if(error)
            [AppDelegate displayAlert:@"Error getting organizations" withMessage:error.localizedDescription on:self];
         self.organizations=[organizations mutableCopy];
         [self.collectionView reloadData];
         
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
    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":self.searchText, @"rated":@"TRUE", @"state": self.stateSearch, @"city": self.citySearch, @"pageNum": @(self.pageNum), @"pageSize":@(RESULTS_SIZE)};
    [[APIManager shared] getOrganizationsWithCompletion:params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
        if(error)
        {
            [AppDelegate displayAlert:@"Error getting organizations" withMessage:error.localizedDescription on:self];
        }
        else{
            [self.organizations addObjectsFromArray:organizations];
            [self.collectionView reloadData];
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
        UICollectionViewCell *tappedCell= sender;
        NSIndexPath *tappedIndex= [self.collectionView indexPathForCell:tappedCell];
        orgVC.org=self.organizations[tappedIndex.item];
        [self.collectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OrgVerticalCell *orgCell= [collectionView dequeueReusableCellWithReuseIdentifier:@"OrgVerticalCell" forIndexPath:indexPath];
    orgCell.org=self.organizations[indexPath.item];
    [orgCell loadData];
    return orgCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.organizations.count;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

    cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0);
    cell.contentView.alpha = 0.3;

    [UIView animateWithDuration:0.75 animations:^{
        cell.layer.transform =CATransform3DIdentity;
        cell.contentView.alpha = 1;
    }];
}

@end
