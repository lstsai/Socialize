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
#import "AppDelegate.h"
#import "EventVerticalCell.h"
#import "Constants.h"
@interface EventSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, EventVerticalCellDelegate, EventDetailsViewControllerDelegate>

@end

@implementation EventSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
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

-(void) didLikeEvent:(Event*)likedEvent{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];
    
    [likedEvents addObject:likedEvent.objectId];
    [self performSelectorInBackground:@selector(addEventToFriendsList:) withObject:likedEvent];
    
    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser saveInBackground];
}
- (void)didUnlikeEvent:(Event*)unlikedEvent{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];

    [likedEvents removeObject:unlikedEvent.objectId];
    [self performSelectorInBackground:@selector(deleteEventFromFriendsList:) withObject:unlikedEvent];
    
    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser saveInBackground];
}
-(void) addEventToFriendsList:(Event*)likedEvent{
    PFQuery *selfAccessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [selfAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    PFObject *friendAccess=[selfAccessQ getFirstObject];
    for(NSString* friend in friendAccess[@"friends"])//get the array of friends for current user
    {
        PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
        [friendQuery includeKey:@"friendAccessible"];
        PFUser* friendProfile=[friendQuery getObjectWithId:friend];
        //if the friend alreay has other friends that like this org
        PFObject * faAcess=friendProfile[@"friendAccessible"];
        if(faAcess[@"friendEvents"][likedEvent.objectId])
        {
            //add own username to that list of friends
            NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
            
            NSMutableArray* list= [friendEvents[likedEvent.objectId] mutableCopy];
            [list addObject:PFUser.currentUser.username];
            
            friendEvents[likedEvent.objectId]=list;
            faAcess[@"friendEvents"]= friendEvents;
        }
        else
        {
            //create that array for the ein and add self as the person who liked it
            NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
            friendEvents[likedEvent.objectId]=@[PFUser.currentUser.username];
            faAcess[@"friendEvents"]= friendEvents;
        }
        //save each friend
        [faAcess saveInBackground];
    }
}

-(void) deleteEventFromFriendsList:(Event*)unlikedEvent{
    PFQuery *selfAccessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [selfAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    PFObject *friendAccess=[selfAccessQ getFirstObject];
    for(NSString* friend in friendAccess[@"friends"])//get the array of friends for current user
       {
           PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
           [friendQuery includeKey:@"friendAccessible"];
           PFUser* friendProfile=[friendQuery getObjectWithId:friend];
           //if the friend alreay has other friends that like this org
           PFObject * faAcess=friendProfile[@"friendAccessible"];
           if(faAcess[@"friendEvents"][unlikedEvent.objectId])
           {
               //add own username to that list of friends
               NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
               
               NSMutableArray* list= [friendEvents[unlikedEvent.objectId] mutableCopy];
               [list removeObject:PFUser.currentUser.username];
               
               friendEvents[unlikedEvent.objectId]=list;
               faAcess[@"friendEvents"]= friendEvents;
           }
           //save each friend
           [faAcess saveInBackground];
       }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EventVerticalCell *eventCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"EventVerticalCell" forIndexPath:indexPath];
    eventCell.event = self.events[indexPath.item];
    eventCell.delegate=self;
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
        eventVC.delegate=self;
        [self.collectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
}

@end
