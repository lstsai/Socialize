//
//  PeopleSearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "PeopleSearchViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ProfileViewController.h"
#import "Constants.h"

@interface PeopleSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation PeopleSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    [self setupLoadingIndicators];
    [self setUpLayout];
    self.resultNum=1;
}
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getPeople:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.collectionView insertSubview:refreshControl atIndex:0];//add into the storyboard

    CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.collectionView addSubview:self.loadingMoreView];

    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.collectionView.contentInset = insets;
}
-(void)setUpLayout{
    
    self.collectionView.frame=self.view.frame;
    UICollectionViewFlowLayout *layout= (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;//cast to supress warning
    layout.minimumInteritemSpacing=MIN_MARGINS;
    layout.minimumLineSpacing=MIN_MARGINS*2;
    
    CGFloat itemWidth=(self.collectionView.frame.size.width-layout.minimumInteritemSpacing*(PEOPLE_PER_LINE-1)-(2*MIN_MARGINS)-(2*SECTION_INSETS))/PEOPLE_PER_LINE;
    layout.itemSize=CGSizeMake(itemWidth, itemWidth);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PersonCell *personCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PersonCell" forIndexPath:indexPath];
    personCell.user = self.people[indexPath.item];
    [personCell loadData];
    return personCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.people.count;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

    cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CELL_TOP_OFFSET, 0);
    cell.contentView.alpha = SHOW_ALPHA*0.3;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        cell.layer.transform =CATransform3DIdentity;
        cell.contentView.alpha = SHOW_ALPHA;
    }];
}

-(void) getPeople:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
        return;
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *userQuery=[PFQuery queryWithClassName:@"_User"];
    [userQuery whereKey:@"username" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchText]];
    [userQuery setLimit:self.resultNum*RESULTS_SIZE];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [AppDelegate displayAlert:@"Error getting people" withMessage:error.localizedDescription on:self];
        else
        {
            self.people=[objects mutableCopy];
            [self.collectionView reloadData];
        }
        if([refreshControl isKindOfClass:[UIRefreshControl class]])
            [refreshControl endRefreshing];
        else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.loadingMoreView stopAnimating];
        }
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
            self.resultNum++;
            CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            self.loadingMoreView.frame = frame;
            [self.loadingMoreView startAnimating];
            [self getPeople:nil];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"profileSegue"])
    {
        ProfileViewController *profileVC=segue.destinationViewController;
        UICollectionViewCell *tappedCell= sender;
        NSIndexPath *tappedIndex= [self.collectionView indexPathForCell:tappedCell];
        profileVC.user=self.people[tappedIndex.item];
        NSLog(@"user %@",profileVC.user.username);
        [self.collectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
}
@end
