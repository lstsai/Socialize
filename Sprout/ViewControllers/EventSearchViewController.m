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
#import "MapViewController.h"

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
/**
Set up the refresh control for the collection view
*/
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getEvents:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.collectionView insertSubview:refreshControl atIndex:0];//add into the storyboard

}
/**
 Setup the layout for the collection view to have some spacing between each cell
 
 */
-(void)setupLayout{
    
    self.collectionView.frame=self.view.frame;
    UICollectionViewFlowLayout *layout= (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;//cast to supress warning
    layout.minimumLineSpacing=MIN_MARGINS*3;
}
/**
Makes a query to get the events based on the search. Ordered by how close the event location is to the
 search location. 
@param[in] refreshControl the activity indicator that is animating if there is one
*/
-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl{
    if([self.searchText isEqualToString:@""])
    {
        if([refreshControl isKindOfClass:[UIRefreshControl class]])
            [refreshControl endRefreshing];
        return;
    }
    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSArray* search= [self.searchText componentsSeparatedByString:@" "];
    
    NSString *regexString = @"^"; //start off the regex
    for(NSString* word in search)//match the words (ignore case) one by one
    {
        regexString = [NSString stringWithFormat:@"%@(?=.*(?i)%@)", regexString, word];
    }
    regexString = [NSString stringWithFormat:@"(?i)%@.*$", regexString]; //finish off the regex

    PFQuery *eventsNameQuery=[PFQuery queryWithClassName:@"Event"];
    PFQuery *eventsDetailsQuery=[PFQuery queryWithClassName:@"Event"];
   
    if(![Helper connectedToInternet])
    {
        [eventsNameQuery fromLocalDatastore];
        [eventsDetailsQuery fromLocalDatastore];
    }
    [eventsNameQuery whereKey:@"name" matchesRegex:regexString];
    [eventsDetailsQuery whereKey:@"details" matchesRegex:regexString];

    PFQuery *eventsQuery=[PFQuery orQueryWithSubqueries:@[eventsNameQuery,eventsDetailsQuery]];
    if(![Helper connectedToInternet])
       [eventsQuery fromLocalDatastore];

    [eventsQuery includeKey:@"author"];
    [eventsQuery whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.locationCoord.latitude longitude:self.locationCoord.longitude]];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error getting events" withMessage:error.localizedDescription on:self];
        else
        {
            self.events=[objects mutableCopy];
            [PFObject unpinAllObjectsWithName:@"Event"];
            [PFObject pinAllInBackground:objects withName:@"Event"];
            [self.collectionView reloadData];
        }
        if([refreshControl isKindOfClass:[UIRefreshControl class]])
            [refreshControl endRefreshing];
        else
            [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
/**
Collection view delegate method. returns a cell to be shown at the index path
@param[in] collectionView the collection view that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EventVerticalCell *eventCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"EventVerticalCell" forIndexPath:indexPath];
    eventCell.event = self.events[indexPath.item];
    [eventCell loadData];
    return eventCell;
}
/**
Collection view delegate method. returns the number of sections that the collection has. This collection only has
 one section so it always returns the total number of events
@param[in] collectionView the collection view that is calling this method
@param[in] section the section in question
@return the number of events
*/
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.events.count;
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
Empty collection view delegate method. Returns the image to be displayed when there are no events
@param[in] scrollView the collection view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptyEvent"];
}
/**
Empty collection view delegate method. Returns the title to be displayed when there are no events
@param[in] scrollView the collection view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Events to show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty collection view delegate method. Returns the message to be displayed when there are no events
@param[in] scrollView the collection view that is empty
@return the message to be shown
*/
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
/**
Empty collection view delegate method. Returns if the empty view should be shown
@param[in] scrollView the collection view that is empty
@return if the empty view shouls be shown
 YES: if there are no events
 NO: there are events
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.events.count==0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"detailSegue"])//takes the user to the details page of event
    {
        EventDetailsViewController *eventVC=segue.destinationViewController;
        UICollectionViewCell *tappedCell= sender;
        NSIndexPath *tappedIndex= [self.collectionView indexPathForCell:tappedCell];
        eventVC.event=self.events[tappedIndex.row];
        [self.collectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
    else if([segue.identifier isEqualToString:@"mapSegue"])//takes user to the map page
    {
        MapViewController *mapVC= segue.destinationViewController;
        mapVC.objects=self.events;
    }
}

@end
