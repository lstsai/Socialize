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
#import "EventDetailsViewController.h"
#import "Helper.h"
#import "EventVerticalCell.h"
#import "Constants.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Post.h"
@interface EventSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation EventSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    self.collectionView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self setupLoadingIndicators];
    [self setupLayout];
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

-(void)setupLayout{
    
    self.collectionView.frame=self.view.frame;
    UICollectionViewFlowLayout *layout= (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;//cast to supress warning
    layout.minimumLineSpacing=MIN_MARGINS*3;
}

-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
    {
        if([refreshControl isKindOfClass:[UIRefreshControl class]])
            [refreshControl endRefreshing];
        return;
    }
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *eventsNameQuery=[PFQuery queryWithClassName:@"Event"];
    [eventsNameQuery whereKey:@"name" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchText]];
    
    PFQuery *eventsDetailsQuery=[PFQuery queryWithClassName:@"Event"];
    [eventsDetailsQuery whereKey:@"details" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchText]];

    PFQuery *eventsQuery=[PFQuery orQueryWithSubqueries:@[eventsNameQuery,eventsDetailsQuery]];
    [eventsQuery includeKey:@"author"];
    [eventsQuery orderByAscending:@"startTime"];
//    if(![self.locationSearch isEqualToString:@""])
//        [eventsQuery whereKey:@"streetAddress" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.locationSearch]];

    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error getting events" withMessage:error.localizedDescription on:self];
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

    cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, CELL_TOP_OFFSET, 0);
    cell.contentView.alpha = SHOW_ALPHA*0.3;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        cell.layer.transform =CATransform3DIdentity;
        cell.contentView.alpha = SHOW_ALPHA;
    }];
}
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptyEvent"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Events to show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Search for more events to display";
    
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
    return self.events.count==0;
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
