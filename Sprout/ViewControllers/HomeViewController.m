//
//  HomeViewController.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "HomeViewController.h"
#import "EventPostCell.h"
#import "OrgPostCell.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "Helper.h"
#import "EventDetailsViewController.h"
#import "OrgDetailsViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ProfileViewController.h"
#import "CommentsViewController.h"
#import "MBProgressHUD.h"
@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, OrgPostCellDelegate, EventPostCellDelegate>

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.pageNum=1;
    [self setupLoadingIndicators];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self performSelectorInBackground:@selector(getPosts:) withObject:nil];
}
/**
 Reload the posts before the view appears, and change color of requests button to indicate if there are
 requests pending
 */
-(void) viewWillAppear:(BOOL)animated{
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self performSelectorInBackground:@selector(getPosts:) withObject:nil];
    [self getRequest];
}
/**
 Gets the friend requests for the user
 */
-(void) getRequest{
    PFObject* selfAccess= [Helper getUserAccess:PFUser.currentUser];
    if([(NSArray*)selfAccess[@"inRequests"] count]>0)//if the user has friend requests pending
        self.requestsButton.tintColor=[UIColor systemBlueColor];
    else
        self.requestsButton.tintColor=[UIColor whiteColor];
}
/**
 setup the refresh control and infinite scroll indicators
 */
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getPosts:) forControlEvents:UIControlEventValueChanged];//add an event listener
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
 Fetches the posts from Parse to be displayed on the user's timeline. Only includes posts created by the user and friends.
 Or posts that are related to a liked event
 Orders the posts by time creates (top is newest post).
 @param[in] refreshControl the refresh control that is animating if there is one
 */
-(void) getPosts:( UIRefreshControl * _Nullable )refreshControl{
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        if(error)
            [Helper displayAlert:@"Error getting friends" withMessage:error.localizedDescription on:self];
        else{
            PFQuery *regpostsQ= [PFQuery queryWithClassName:@"Post"];
            [regpostsQ whereKey:@"groupPost" equalTo:@(NO)];
            NSArray *friendsAndSelf=[friends arrayByAddingObject:PFUser.currentUser];
            [regpostsQ whereKey:@"author" containedIn:friendsAndSelf];
            PFQuery* groupPostQ=[PFQuery queryWithClassName:@"Post"];
            [groupPostQ whereKey:@"groupPost" equalTo:@(YES)];
            NSMutableArray* eventsList=[NSMutableArray new];
            //get all the events that the user has liked
            for(NSString* eventID in PFUser.currentUser[@"likedEvents"])
            {
                [eventsList addObject:[PFQuery getObjectOfClass:@"Event" objectId:eventID]];
            }
            [groupPostQ whereKey:@"event" containedIn:eventsList];
            PFQuery* postsQ=[PFQuery orQueryWithSubqueries:@[regpostsQ, groupPostQ]];
            [postsQ includeKey:@"event"];
            [postsQ includeKey:@"author"];
            [postsQ orderByDescending:@"createdAt"];
            [postsQ setLimit:RESULTS_SIZE*self.pageNum];

            [postsQ findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(error)
                {
                    [Helper displayAlert:@"Error Loading Posts" withMessage:error.localizedDescription on:self];
                }
                else{
                    self.posts=[objects mutableCopy];
                    [self.tableView reloadData];
                }
                if(refreshControl)
                    [refreshControl endRefreshing];
                else
                    [self.loadingMoreView stopAnimating];
                [MBProgressHUD hideHUDForView:self.tableView animated:YES];

            }];
        }
    }];
}
/**
 Table view delegate method. returns a cell to be shown. Depending on which type of post is at the index path,
 show either a event post or a organization post
 @param[in] tableView the table that is calling this method
 @param[in] indexPath the path for the returned cell to be displayed
 @return the cell that should be shown in the passed indexpath
 */
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Post *currPost=self.posts[indexPath.row];
    if(currPost.event)
    {
        EventPostCell *epc=[tableView dequeueReusableCellWithIdentifier:@"EventPostCell"];
        epc.post=currPost;
        epc.delegate=self;
        [epc loadData];
        return epc;
    }
    else{
        OrgPostCell *opc=[tableView dequeueReusableCellWithIdentifier:@"OrgPostCell"];
        opc.post=currPost;
        opc.delegate=self;
        [opc loadData];
        return opc;
    }
}
/**
Table view delegate method. returns the number of sections that the table has. This table only has
 one section so it always returns the total number of posts
@param[in] tableView the table that is calling this method
@param[in] section the section in question
@return the number of posts
*/
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}
/**
Empty table view delegate method. Returns the image to be displayed when there are no posts
@param[in] scrollView the table view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"share-post"];
}
/**
Empty table view delegate method. Returns the title to be displayed when there are no posts
@param[in] scrollView the table view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Posts to Show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty table view delegate method. Returns the message to be displayed when there are no posts
@param[in] scrollView the table view that is empty
@return the message to be shown
*/
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Add friends, like some events or organizations, or create a post!";
    
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
 YES: if there are no posts
 NO: there are posts
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.posts.count==0;
}
/**
 Triggered when the user taps on a profile image on a post. Takes the user to the
 tapped user's profile page
 @param[in] user the user that was tapped
 */
-(void) didTapUser:(PFUser *)user{
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}
/**
 Triggered when the uses presses the comment button on a particular post
 @param[in] post the post that the user tapped on
 */
- (void)didTapComment:(nonnull Post *)post {
    [self performSegueWithIdentifier:@"commentSegue" sender:post];
}
/**
Triggered when the user scrolls on the table view. Determines if the program should load more data
 depending on how far the user has scrolled and if more data is already loading. Calls the getPosts method
 if more posts are needed.
@param[in] scrollView table view that is being scrolled
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading && self.posts.count!=0)
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
               [self getPosts:nil];
           }

       }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"eventSegue"])//presents the event details page
    {
        EventDetailsViewController *evc= segue.destinationViewController;
        UITableViewCell* tappedcell=sender;
        NSIndexPath *tappedIndex= [self.tableView indexPathForCell:tappedcell];
        evc.event=((EventPostCell*)tappedcell).event;
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"orgSegue"])//presents the org details page
    {
        OrgDetailsViewController *ovc= segue.destinationViewController;
        UITableViewCell* tappedcell=sender;
        NSIndexPath *tappedIndex= [self.tableView indexPathForCell:tappedcell];
        ovc.org=((OrgPostCell*)tappedcell).org;
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"profileSegue"]){//presents the user's profile page
        ProfileViewController* profileVC= segue.destinationViewController;
        profileVC.user=(PFUser*)sender;
    }
    else if([segue.identifier isEqualToString:@"commentSegue"])
    {
        CommentsViewController *commentVC=segue.destinationViewController;
        commentVC.post=(Post*)sender;
    }
    
}



@end
