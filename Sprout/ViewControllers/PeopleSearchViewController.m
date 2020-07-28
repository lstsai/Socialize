//
//  PeopleSearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "PeopleSearchViewController.h"
#import "MBProgressHUD.h"
#import "Helper.h"
#import "Constants.h"
#import "ProfileViewController.h"
#import "Constants.h"
#import "UIScrollView+EmptyDataSet.h"

@interface PeopleSearchViewController ()< UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation PeopleSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    self.collectionView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self setupLoadingIndicators];
    [self setUpLayout];
    self.resultNum=1;
}
/**
Set up the refresh control and infinite scroll for the collection view
*/
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
/**
Setup the layout for the collection view to have 2 cells per row and margins
*/
-(void)setUpLayout{
    
    self.collectionView.frame=self.view.frame;
    UICollectionViewFlowLayout *layout= (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;//cast to supress warning
    layout.minimumInteritemSpacing=MIN_MARGINS;
    layout.minimumLineSpacing=MIN_MARGINS*2;
    
    CGFloat itemWidth=(self.collectionView.frame.size.width-layout.minimumInteritemSpacing*(PEOPLE_PER_LINE-1)-(2*MIN_MARGINS)-(2*SECTION_INSETS))/PEOPLE_PER_LINE;
    layout.itemSize=CGSizeMake(itemWidth, itemWidth);
}
/**
Collection view delegate method. returns a cell to be shown at the index path
@param[in] collectionView the collection view that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PersonCell *personCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PersonCell" forIndexPath:indexPath];
    personCell.user = self.people[indexPath.item];
    [personCell loadData];
    return personCell;
}
/**
Collection view delegate method. returns the number of sections that the collection has. This collection only has
 one section so it always returns the total number of profiles
@param[in] collectionView the collection view that is calling this method
@param[in] section the section in question
@return the number of profiles
*/
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.people.count;
}
/**
Collection view delegate method. Configures the animations for the cell that is about to be shown.
 Shifts the cell's starting top position lower and animates it so that the it shifts up when scrolled.
  Also makes gradually makes the cell more opaque
@param[in] collectionView the table view that is empty
@param[in] cell the cell that is about to be shown
@param[in] indexPath the index path of the cell
*/
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

    cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CELL_TOP_OFFSET, 0);
    cell.contentView.alpha = SHOW_ALPHA*0.3;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        cell.layer.transform =CATransform3DIdentity;
        cell.contentView.alpha = SHOW_ALPHA;
    }];
}
/**
Makes a query to get the users whose username matches the search
@param[in] refreshControl the activity indicator that is animating if there is one
*/
-(void) getPeople:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
    {
        if([refreshControl isKindOfClass:[UIRefreshControl class]])
            [refreshControl endRefreshing];
        return;
    }
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *nameQuery=[PFQuery queryWithClassName:@"_User"];
    [nameQuery whereKey:@"username" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchText]];
    PFQuery *bioQuery=[PFQuery queryWithClassName:@"_User"];
    [bioQuery whereKey:@"bio" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchText]];
    
    PFQuery* userQuery=[PFQuery orQueryWithSubqueries:@[nameQuery, bioQuery]];
    [userQuery setLimit:self.resultNum*RESULTS_SIZE];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error getting people" withMessage:error.localizedDescription on:self];
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
/**
Triggered when the user scrolls on the collection view. Determines if the program should load more data
 depending on how far the user has scrolled and if more data is already loading. Calls the getPeople method
 if more users are needed. Update result number to retrieve new users
@param[in] scrollView collection view that is being scrolled
*/
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
/**
Empty collection view delegate method. Returns the image to be displayed when there are no users
@param[in] scrollView the collection view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"group"];
}
/**
Empty collection view delegate method. Returns the title to be displayed when there are no users
@param[in] scrollView the collection view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Users to Show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty collection view delegate method. Returns the message to be displayed when there are no users
@param[in] scrollView the collection view that is empty
@return the message to be shown
*/
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Search for more users to display";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:EMPTY_MESSAGE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty collection view delegate method. Returns if the empty view should be shown
@param[in] scrollView the collection view that is empty
@return if the empty view shouls be shown
 YES: if there are no users
 NO: there are users
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.people.count==0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"profileSegue"])//takes the user to the profile page
    {
        ProfileViewController *profileVC= segue.destinationViewController;
        UICollectionViewCell *tappedCell= sender;
        NSIndexPath *tappedIndex= [self.collectionView indexPathForCell:tappedCell];
        profileVC.user=self.people[tappedIndex.item];
        [self.collectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
}
@end
